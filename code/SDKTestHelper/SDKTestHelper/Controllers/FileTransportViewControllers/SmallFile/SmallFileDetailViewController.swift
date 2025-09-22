//
//  SmallFileDetailViewController.swift
//  WatchTest
//
//  Created by EzioChan on 2023/11/9.
//

import UIKit

class SmallFileDetailViewController: BaseViewController {
    let subTable = UITableView()
    let itemsArray = BehaviorRelay<[String]>(value: [])

    let subTextView = UITextView()
    let subTextLab = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        requestData()
    }

    override func initUI() {
        super.initUI()
        navigationView.title = R.localStr.downloadedFile()
        navigationView.leftBtn.setTitle(R.localStr.back(), for: .normal)
        view.addSubview(subTable)
        view.addSubview(subTextLab)
        view.addSubview(subTextView)

        subTable.register(UITableViewCell.self, forCellReuseIdentifier: "smallFileDetailCell")

        subTextView.font = UIFont.systemFont(ofSize: 14)
        subTextView.textColor = UIColor.black
        subTextView.isEditable = false

        subTextLab.text = R.localStr.fileContent()
        subTextLab.font = UIFont.systemFont(ofSize: 15)
        subTextLab.textColor = UIColor.black

        subTable.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(navigationView.snp.bottom).offset(5)
            make.height.equalTo(300)
        }
        subTextLab.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(10)
            make.top.equalTo(subTable.snp.bottom)
        }
        subTextView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(10)
            make.top.equalTo(subTextLab.snp.bottom)
            make.bottom.equalToSuperview()
        }
    }

    override func initData() {
        super.initData()
        navigationView.leftBtn.rx.tap.subscribe(onNext: { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }).disposed(by: disposeBag)

        itemsArray.bind(to: subTable.rx
            .items(cellIdentifier: "smallFileDetailCell",
                   cellType: UITableViewCell.self))
        {
            _, item, cell in
            let fileName = "/" + (item as NSString).lastPathComponent.uppercased()
            let size = _R.sizeForFilePath(item)
            cell.textLabel?.text = fileName + ":\(_R.covertToFileString(size))"
        }.disposed(by: disposeBag)

        subTable.rx.modelDeleted(String.self)
            .subscribe(onNext: { [weak self] item in
                try? FileManager.default.removeItem(atPath: item)
                self?.requestData()
            }).disposed(by: disposeBag)

        subTable.rx.modelSelected(String.self).subscribe(onNext: {
            [weak self] item in
            guard let dt = try? Data(contentsOf: URL(fileURLWithPath: item)) else {
                return
            }
            self?.subTextView.text = dt.eHexPlus
            self?.subTable.reloadData()

        }).disposed(by: disposeBag)
    }

    private func requestData() {
        let path = _R.path.smallFiles

        if let files = try? FileManager.default.contentsOfDirectory(atPath: path) {
            var filesArray = [String]()
            for file in files {
                // weather folder
                let p = path + "/" + file
                var isDirctory = ObjCBool(false)
                let isExist = FileManager.default.fileExists(atPath: p,
                                                             isDirectory: &isDirctory)
                if isExist && !isDirctory.boolValue {
                    filesArray.append(p)
                }
            }
            itemsArray.accept(filesArray)
        }
    }
}

private extension Data {
    var eHexPlus: String {
        map {
            String(format: " %02x", $0).uppercased()
        }.joined()
    }
}
