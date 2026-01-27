//
//  ContactViewController.swift
//  WatchTest
//
//  Created by EzioChan on 2023/11/1.
//

import UIKit

class ContactViewController: BaseViewController {
    let subTable = UITableView()
    let itemArray = BehaviorRelay<[ContactModel]>(value: [])
    let getContactBtn = UIButton()
    let addContactBtn = UIButton()
    let deleteContactBtn = UIButton()
    private var dtContacts = Data()
    private var contactsFM: JLModel_SmallFile?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func initUI() {
        super.initUI()
        view.addSubview(getContactBtn)
        view.addSubview(subTable)
        view.addSubview(deleteContactBtn)
        view.addSubview(addContactBtn)

        navigationView.title = R.localStr.syncContacts()
        navigationView.leftBtn.setTitle(R.localStr.back(), for: .normal)

        getContactBtn.setTitle(R.localStr.getContacts(), for: .normal)
        getContactBtn.backgroundColor = UIColor.eHex("#9C27B0")
        getContactBtn.layer.cornerRadius = 5
        getContactBtn.layer.masksToBounds = true
        getContactBtn.setTitleColor(UIColor.white, for: .normal)
        getContactBtn.setTitleColor(UIColor.lightGray, for: .highlighted)

        addContactBtn.setTitle(R.localStr.add(), for: .normal)
        addContactBtn.backgroundColor = UIColor.eHex("2196F3")
        addContactBtn.layer.cornerRadius = 5
        addContactBtn.layer.masksToBounds = true
        addContactBtn.setTitleColor(UIColor.white, for: .normal)
        addContactBtn.setTitleColor(UIColor.lightGray, for: .highlighted)

        deleteContactBtn.setTitle(R.localStr.delete(), for: .normal)
        deleteContactBtn.backgroundColor = UIColor.eHex("F44336")
        deleteContactBtn.layer.cornerRadius = 5
        deleteContactBtn.layer.masksToBounds = true
        deleteContactBtn.setTitleColor(UIColor.white, for: .normal)
        deleteContactBtn.setTitleColor(UIColor.lightGray, for: .highlighted)

        subTable.register(ContactCell.self, forCellReuseIdentifier: "ContactCell")
        subTable.rowHeight = 65
        subTable.tableFooterView = UIView()
        itemArray.bind(to: subTable.rx.items(cellIdentifier: "ContactCell", cellType: ContactCell.self)) { _, item, cell in
            cell.bind(item)
        }.disposed(by: disposeBag)

        getContactBtn.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(24)
            make.height.equalTo(35)
            make.top.equalTo(navigationView.snp.bottom).offset(10)
        }

        subTable.snp.makeConstraints { make in
            make.top.equalTo(getContactBtn.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(300)
        }

        deleteContactBtn.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(24)
            make.height.equalTo(35)
            make.top.equalTo(subTable.snp.bottom).offset(10)
        }

        addContactBtn.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(24)
            make.height.equalTo(35)
            make.top.equalTo(deleteContactBtn.snp.bottom).offset(10)
        }
    }

    override func initData() {
        super.initData()

        navigationView.leftBtn.rx.tap.subscribe(onNext: { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }).disposed(by: disposeBag)

        getContactBtn.rx.tap.subscribe(onNext: { [weak self] in

            guard let self = self else { return }
            // Get Contacts File
            BleManager.shared.currentCmdMgr?.mSmallFileManager
                .cmdSmallFileQueryType(.contacts, result: { fileList in
                    if let file = fileList?.first {
                        self.contactsFM = file
                        self.dtContacts.removeAll()
                        BleManager.shared.currentCmdMgr?.mSmallFileManager
                            .cmdSmallFileRead(file, result: { op, _, dt in
                                switch op {
                                case .crcError, .fail, .unknown, .excess, .timeout:
                                    break
                                case .doing:
                                    if let dt = dt {
                                        self.dtContacts.append(dt)
                                    }
                                case .suceess:
                                    if let dt = dt {
                                        self.dtContacts.append(dt)
                                    }
                                    self.itemArray
                                        .accept(ContactModel
                                            .beObjcs(self.dtContacts))
                                default:
                                    break
                                }
                            })
                    }
                })

        }).disposed(by: disposeBag)

        addContactBtn.rx.tap.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            if self.itemArray.value.count > 5 {
                self.view.makeToast(R.localStr.only5CanBeAdded())
                return
            }
            var items = self.itemArray.value
            let person = ContactModel()
            let fmdate = DateFormatter()
            fmdate.dateFormat = "HH:mm:ss"
            person.fullName = "Andy Liu" + fmdate.string(from: Date())
            person.phoneNum = "12345678910"
            items.append(person)
            self.itemArray.accept(items)
            self.pushToDevice()
        }).disposed(by: disposeBag)

        deleteContactBtn.rx.tap.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            if self.itemArray.value.count < 1 {
                self.view.makeToast(R.localStr.atLeastOneContactMustBeAdded())
                return
            }
            var items = self.itemArray.value
            items.removeFirst()
            self.itemArray.accept(items)
            self.pushToDevice()

        }).disposed(by: disposeBag)
    }

    func pushToDevice() {
        let dt = ContactModel.beData(itemArray.value)

        guard let fileModel = contactsFM else {
            BleManager.shared.currentCmdMgr?.mSmallFileManager
                .cmdSmallFileNew(dt, type: .contacts, result: { op, _, _ in
                    switch op {
                    case .crcError, .fail, .unknown, .excess, .timeout:
                        self.view.makeToast(R.localStr.transportError(), position: .center)
                    case .doing:
                        self.view.makeToast(R.localStr.transmitting(), position: .center)
                    case .suceess:
                        self.view.makeToast(R.localStr.transportedSuccessfully(), position: .center)
                    default:
                        break
                    }
                })
            return
        }
        if dt.count == 0 {
            BleManager.shared.currentCmdMgr?.mSmallFileManager
                .cmdSmallFileDelete(fileModel, result: { op in
                    switch op {
                    case .crcError, .fail, .unknown, .excess, .timeout:
                        self.view.makeToast(R.localStr.transportError(), position: .center)
                    case .doing:
                        self.view.makeToast(R.localStr.transmitting(), position: .center)
                    case .suceess:
                        self.view.makeToast(R.localStr.transportedSuccessfully(), position: .center)
                    default:
                        break
                    }
                })
            contactsFM = nil
            return
        }

        BleManager.shared.currentCmdMgr?.mSmallFileManager
            .cmdSmallFileUpdate(fileModel, data: dt, result: { op, _ in
                switch op {
                case .crcError, .fail, .unknown, .excess, .timeout:
                    self.view.makeToast(R.localStr.transportError(), position: .center)
                case .doing:
                    self.view.makeToast(R.localStr.transmitting(), position: .center)
                case .suceess:
                    self.view.makeToast(R.localStr.transportedSuccessfully(), position: .center)
                default:
                    break
                }
            })
    }
}

class ContactModel: PersonModel {
    static func beObjcs(_ basicData: Data) -> [ContactModel] {
        var len = 0
        var list = [ContactModel]()
        while len < basicData.count {
            let dtName = JL_Tools.data(basicData, r: len, l: 20)
            let dtPhone = JL_Tools.data(basicData, r: len + 20, l: 20)
            len += 40
            let name = String(data: dtName, encoding: .utf8)!
            let phone = String(data: dtPhone, encoding: .utf8)!
            let model = ContactModel()
            model.fullName = name
            model.phoneNum = phone
            list.append(model)
        }
        return list
    }

    static func beData(_ list: [ContactModel]) -> Data {
        ContactsTool.setContactsToData(list)
    }
}

private class ContactCell: UITableViewCell {
    let mainLab = UILabel()
    let secondLab = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(mainLab)
        contentView.addSubview(secondLab)

        mainLab.font = UIFont.systemFont(ofSize: 15)
        mainLab.textColor = UIColor.eHex("#333333")
        mainLab.adjustsFontSizeToFitWidth = true
        secondLab.font = UIFont.systemFont(ofSize: 12)
        secondLab.textColor = UIColor.eHex("#999999")
        secondLab.adjustsFontSizeToFitWidth = true

        mainLab.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().inset(4)
            make.right.equalToSuperview().inset(16)
            make.height.equalTo(30)
        }

        secondLab.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalTo(mainLab.snp.bottom).offset(3)
            make.right.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(4)
        }
    }

    func bind(_ model: ContactModel) {
        mainLab.text = model.fullName
        secondLab.text = model.phoneNum
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
