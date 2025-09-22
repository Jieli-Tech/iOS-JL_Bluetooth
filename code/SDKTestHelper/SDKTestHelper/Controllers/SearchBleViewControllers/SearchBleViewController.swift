//
//  SearchBleViewController.swift
//  WatchTest
//
//  Created by EzioChan on 2023/10/25.
//

import UIKit

class SearchBleViewController: BaseViewController {
    let textField = UITextField()
    let tableView = UITableView()
    let textLab = UILabel()
    var itemsArray: [JL_EntityM] = []
    private let currentAttDeviceTable = UITableView()
    var attDeviceArray = BehaviorRelay<[CBPeripheral]>(value: [])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        BleManager.shared.startSearchBle()
        NotificationCenter.default.addObserver(self, selector: #selector(connectStatusChange(_:)), name: NSNotification.Name(kJL_BLE_M_ENTITY_CONNECTED), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(connectStatusFailed(_:)), name: NSNotification.Name(kJL_BLE_M_ENTITY_CONNECTED), object: nil)
    }

    override func initUI() {
        super.initUI()
        navigationView.title = R.localStr.searchDevice()
        navigationView.leftBtn.setTitle(R.localStr.back(), for: .normal)
        navigationView.rightBtn.isHidden = false
        navigationView.rightBtn.setTitle(R.localStr.search(), for: .normal)

        textLab.text = R.localStr.filterPrefix()
        textLab.font = .systemFont(ofSize: 15)
        textLab.textColor = .black
        view.addSubview(textLab)

        textField.placeholder = R.localStr.pleaseEnterTheFilterPrefix() // "Please enter the filter prefix"
        textField.font = .systemFont(ofSize: 15)
        textField.keyboardType = .default
        textField.autocorrectionType = .no
        textField.borderStyle = .roundedRect
        textField.returnKeyType = .done
        textField.clearButtonMode = .whileEditing
        textField.delegate = self
        view.addSubview(textField)
        
        currentAttDeviceTable.register(UITableViewCell.self, forCellReuseIdentifier: "ATTCell")
        currentAttDeviceTable.rowHeight = 60
        currentAttDeviceTable.separatorStyle = .none
        currentAttDeviceTable.isScrollEnabled = false
        view.addSubview(currentAttDeviceTable)

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "BleCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.rowHeight = 60
        view.addSubview(tableView)

        textLab.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.top.equalTo(navigationView.snp.bottom).offset(10)
            make.right.equalTo(textField.snp.left).offset(-10)
            make.height.equalTo(30)
        }
        
        textField.snp.makeConstraints { make in
            make.left.equalTo(textLab.snp.right).offset(10)
            make.right.equalToSuperview().inset(20)
            make.top.equalTo(navigationView.snp.bottom).offset(10)
            make.height.equalTo(30)
        }
        
        currentAttDeviceTable.snp.makeConstraints { make in
            make.left.right.equalToSuperview().offset(20)
            make.top.equalTo(textField.snp.bottom).offset(10)
            make.height.equalTo(0)
        }

        tableView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalTo(currentAttDeviceTable.snp.bottom).offset(10)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
        }
        
        attDeviceArray.bind(to: currentAttDeviceTable.rx.items(cellIdentifier: "ATTCell", cellType: UITableViewCell.self)) { _, peripheral, cell in
            cell.textLabel?.text = peripheral.name
            cell.textLabel?.textColor = .white
            cell.textLabel?.backgroundColor = .random()
        }.disposed(by: disposeBag)
        
        BleManager.shared.discoverAttDevices.subscribe (onNext: { [weak self] items in
            var tmp: [CBPeripheral] = []
            for item in items {
                tmp.append(item.value)
            }
            self?.attDeviceArray.accept(tmp)
            self?.currentAttDeviceTable.snp.updateConstraints({ make in
                make.height.equalTo(tmp.count * 60)
            })
        }).disposed(by: disposeBag)
    }

    override func initData() {
        super.initData()

        NotificationCenter.default.addObserver(self, selector: #selector(handleSearchList(_:)), name: NSNotification.Name(kJL_BLE_M_FOUND), object: nil)

        navigationView.leftBtn.rx.tap.subscribe { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }.disposed(by: disposeBag)

        navigationView.rightBtn.rx.tap.subscribe { _ in
            BleManager.shared.startSearchBle()
        }.disposed(by: disposeBag)
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        BleManager.shared.stopSearchBle()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(kJL_BLE_M_FOUND), object: nil)
    }

    @objc func handleSearchList(_ notify: Notification) {
        fillter()
    }

    private func fillter() {
        let arr: [JL_EntityM] = BleManager.shared.blesArray
        itemsArray = arr.filter { item in
            let name = item.mPeripheral.name ?? ""
            // ECPrintInfo(item.mPeripheral, self, "\(#function)", #line)
            let str = (textField.text == "" ? name : textField.text!)
            return name.contains(str)
        }
        tableView.reloadData()
    }

    @objc private func connectStatusChange(_: NSNotification) {
        navigationController?.popViewController(animated: true)
    }

    @objc private func connectStatusFailed(_: NSNotification) {
        view.makeToast(R.localStr.connectFailed(), position: .center)
    }
}

extension SearchBleViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_: UITextField) -> Bool {
        textField.endEditing(true)
        fillter()
        return true
    }
}

extension SearchBleViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        itemsArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BleCell", for: indexPath)
        cell.textLabel?.text = itemsArray[indexPath.row].mPeripheral.name
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = itemsArray[indexPath.row]
        BleManager.shared.connectEntity(item)
    }
}
