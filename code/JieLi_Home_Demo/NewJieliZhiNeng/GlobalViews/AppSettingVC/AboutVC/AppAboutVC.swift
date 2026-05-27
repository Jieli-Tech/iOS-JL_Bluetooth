//
//  AppAboutVC.swift
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2026/3/30.
//  Copyright © 2026 杰理科技. All rights reserved.
//

import UIKit
import SnapKit

@objcMembers
class AppAboutVC: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    private var topImv: UIImageView!
    private var backBtn: UIButton!
    private var titleName: UILabel!
    private var subTitleView: UIView!
    
    private var currentVerUIView: UIView!
    private var aboutTableView: UITableView!
    private var itemArray: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addNote()
    }
    
    override func initUI() {
        super.initUI()
        
        self.navigationView.titleLab.text = R.Language.lan("about")
        self.view.backgroundColor = UIColor(red: 248/255.0, green: 250/255.0, blue: 252/255.0, alpha: 1.0)
        
        // 顶部图标
        topImv = UIImageView()
        topImv.image = UIImage(named: "Theme.bundle/logo_1")
        topImv.contentMode = .scaleAspectFill
        self.view.addSubview(topImv)
        
        topImv.snp.makeConstraints { make in
            make.top.equalTo(self.view).offset(180)
            make.centerX.equalTo(self.view)
            make.width.height.equalTo(118)
        }
        
        let gapes = UILongPressGestureRecognizer(target: self, action: #selector(longPressAction))
        gapes.minimumPressDuration = 4
        self.view.addGestureRecognizer(gapes)
        
        aboutTableView = UITableView()
        aboutTableView.delegate = self
        aboutTableView.dataSource = self
        aboutTableView.isScrollEnabled = false
        aboutTableView.tag = 0
        aboutTableView.rowHeight = 55
        aboutTableView.separatorColor = UIColor(red: 238/255.0, green: 238/255.0, blue: 238/255.0, alpha: 1.0)
        self.view.addSubview(aboutTableView)
        
        aboutTableView.snp.makeConstraints { make in
            make.top.equalTo(topImv.snp.bottom).offset(80)
            make.left.right.equalTo(self.view)
            make.height.equalTo(55 * 3)
        }
        
        let tmpArray = [R.Language.lan("firmware_current_version"), R.Language.lan("user_agreement"), R.Language.lan("privacy_policy_name")]
        
        itemArray.removeAll()
        itemArray.append(contentsOf: tmpArray)
        aboutTableView.reloadData()
    }
    
    // MARK: - long press
    @objc func longPressAction() {
        let vc = DebugSettingVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - tableview delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let IDCell = "lcell"
        var cell = tableView.dequeueReusableCell(withIdentifier: IDCell)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: IDCell)
        }
        
        cell?.contentView.backgroundColor = UIColor.white
        
        cell?.textLabel?.text = itemArray[indexPath.row]
        cell?.textLabel?.font = UIFont(name: "PingFang SC", size: 14)
        cell?.textLabel?.textColor = UIColor(red: 36/255.0, green: 36/255.0, blue: 36/255.0, alpha: 1.0)
        
        if #available(iOS 12.0, *) {
            if self.traitCollection.userInterfaceStyle == .dark {
                cell?.textLabel?.alpha = 0.7
            } else {
                cell?.textLabel?.alpha = 1.0
            }
        } else {
            cell?.textLabel?.alpha = 1.0
        }
        
        if indexPath.row == 0 {
            let currentVerCodeLabel = UILabel()
            currentVerCodeLabel.numberOfLines = 0
            cell?.contentView.addSubview(currentVerCodeLabel)
            
            currentVerCodeLabel.snp.makeConstraints { make in
                make.right.equalTo(cell!.contentView).offset(-14.5)
                make.centerY.equalTo(cell!.contentView)
            }
            
            if let infoDic = Bundle.main.infoDictionary, let appVersion = infoDic["CFBundleShortVersionString"] as? String {
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont(name: "PingFang SC", size: 14) ?? UIFont.systemFont(ofSize: 14),
                    .foregroundColor: UIColor(red: 152/255.0, green: 152/255.0, blue: 152/255.0, alpha: 1.0)
                ]
                let currentVerCodeStr = NSAttributedString(string: appVersion, attributes: attributes)
                currentVerCodeLabel.attributedText = currentVerCodeStr
            }
        } else {
            let nextBtn = UIButton()
            nextBtn.setImage(UIImage(named: "Theme.bundle/icon_app_settings_next"), for: .normal)
            cell?.contentView.addSubview(nextBtn)
            
            nextBtn.snp.makeConstraints { make in
                make.right.equalTo(cell!.contentView).offset(-14.5)
                make.centerY.equalTo(cell!.contentView)
                make.width.equalTo(24.5)
                make.height.equalTo(11)
            }
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 1 {
            let vc = UserProfileVC()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        if indexPath.row == 2 {
            let vc = PrivacyPolicyVC()
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc func noteDeviceChange(_ note: Notification) {
        if let typeValue = note.object as? Int, typeValue == 1 { // JLDeviceChangeTypeInUseOffline = 1
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    func addNote() {
        JL_Tools.add(kUI_JL_DEVICE_CHANGE, action: #selector(noteDeviceChange(_:)), own: self)
    }
    
    deinit {
        JL_Tools.remove(nil, own: self)
    }
}
