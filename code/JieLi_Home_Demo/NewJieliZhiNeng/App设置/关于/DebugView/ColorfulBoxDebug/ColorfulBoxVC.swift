//
//  ColorfulBoxVC.swift
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2023/12/1.
//  Copyright © 2023 杰理科技. All rights reserved.
//

import UIKit

class ColorfulBoxVC: DebugBasicViewController, JLPublicSettingProtocol {


    private let jldevPlayer = JLDevPlayerCtrl()
    private let setCtrl = JLPublicSetting()
    override func viewDidLoad() {
        super.viewDidLoad()
        naviView.titleLab.text = "ColorfulBox"
        setCtrl.delegate = self
        
    }
    
    override func initData() {
        super.initData()
        let _ = R.shared
        itemArray = NSMutableArray(array: ["时间同步","电量获取","暂停/播放","上一曲","下一曲","随机音量","anc/通透/关闭","EQ设置","闹钟设置","游戏/播放模式","随机亮度","手电筒开关","找耳机","大文件"])
        
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        
        guard let cmdManager = JL_RunSDK.sharedMe().mBleEntityM?.mCmdManager else { return  }
        
        switch indexPath.row {
        case 0:
            let date = DateObj.make()
            cmdManager.mSystemTime.cmdSetSystemYear(date.year, month: date.month, day: date.day, hour: date.hour, minute: date.minute, second: date.second)
            self.view.makeToast("当前设置时间：\(date.beString())",position: .center)
        case 1:
            cmdManager.mTwsManager.cmdHeadsetGetAdvFlag(.getElectricity) { [weak self](dict) in
                guard let self = self else {return}
                let str = cmdManager.mTwsManager.electricity.logProperties()
                self.view.makeToast(str,position: .center)
            }
            break
        case 2:
            jldevPlayer.cmdPlayerCtrl(0x01, second: 0x00, manager: cmdManager){[weak self](status,sn,data)  in
                if status == .success {
                    self?.view.makeToast("播放/暂停成功")
                }
            }
        case 3:
            jldevPlayer.cmdPlayerCtrl(0x02, second: 0x00, manager: cmdManager){[weak self](status,sn,data)  in
                if status == .success {
                    self?.view.makeToast("上一曲成功")
                }
            }
        case 4:
            jldevPlayer.cmdPlayerCtrl(0x03, second: 0x00, manager: cmdManager){[weak self](status,sn,data)  in
                if status == .success {
                    self?.view.makeToast("下一曲成功")
                }
            }
        case 5:
            let maxVolume = cmdManager.getDeviceModel().maxVol == 0 ? 100 : cmdManager.getDeviceModel().maxVol
            
            let minVolume = 0
            let randomVolume = UInt8.random(in: UInt8(minVolume)..<UInt8(maxVolume))
            
            cmdManager.mSystemVolume.cmdSetSystemVolume(randomVolume) { [weak self](status, sn, data) in
                if status == .success {
                    self?.view.makeToast("随机音量成功:\n当前设置：\(randomVolume)")
                }
            }
        case 6:
            
            guard let models = cmdManager.getDeviceModel().mAncModeArray as? [JLModel_ANC] else{return}
            if let model = models.randomElement(){
                cmdManager.mTwsManager.cmdSetANC(model)
                var str = ""
                if model.mAncMode == .noiseReduction {
                    str = "anc"
                }else if model.mAncMode == .normal {
                    str = "关闭"
                }else if model.mAncMode == .transparent {
                    str = "通透"
                }
                self.view.makeToast("当前设置：\(str)")
            }
        case 7:
            let eqDef = cmdManager.mSystemEQ.eqDefaultArray
            if let randomEQ = eqDef.randomElement(){
                var str = ""
                switch randomEQ.mMode {
                case .NORMAL:
                    str = "自然"
                case .ROCK:
                    str = "摇滚"
                case .POP:
                    str = "流行"
                case .CLASSIC:
                    str = "古典"
                case .JAZZ:
                    str = "爵士"
                case .COUNTRY:
                    str = "乡村"
                case .CUSTOM:
                    str = "自定义"
                case .LATIN:
                    str = "拉丁"
                case .DANCE:
                    str = "跳舞"
                @unknown default:
                    str = "unKnow"
                }
                cmdManager.mSystemEQ.cmdSetSystemEQ(randomEQ.mMode, params: randomEQ.mEqArray)
                self.view.makeToast("当前设置：\(str)")
            }
        case 8:
            let model = JLModel_RTC()
            let date = DateObj.make()
            model.rtcYear = date.year
            model.rtcMonth = date.month
            model.rtcDay = date.day
            model.rtcHour = date.hour
            model.rtcMin = date.minute
            model.rtcSec = date.second+10
            model.rtcIndex = 0
            model.rtcMode = 0
            model.rtcEnable = true
            
            if cmdManager.mAlarmClockManager.rtcAlarmType == .YES{
                if let rings = cmdManager.mAlarmClockManager.rtcDfRings as? [JLModel_Ring]{
                    let r = rings.randomElement()!
                    model.ringInfo = RTC_RingInfo()
                    model.ringInfo.clust = 0
                    model.ringInfo.dev = 0
                    model.ringInfo.type = 0
                    model.ringInfo.data = r.name.data(using: .utf8) ?? Data()
                    model.ringInfo.len = UInt8(model.ringInfo.data.count)
                }
                
            }
            cmdManager.mAlarmClockManager.cmdRtcSetArray([model]){
                [weak self](status, sn, data) in
                if status == .success {
                    self?.view.makeToast("设置闹钟成功:\(date.beString()) \n 10s 后响铃")
                }
            }
        case 9:
            if cmdManager.mTwsManager.workMode == 1{
                cmdManager.mTwsManager.cmdHeadsetWorkSettingMode(1)
                self.view.makeToast("游戏模式")
            }else{
                cmdManager.mTwsManager.cmdHeadsetWorkSettingMode(0)
                self.view.makeToast("正常播放模式")
            }
        case 10:
            //TODO: 屏幕亮度设置
            let l = uint8(arc4random() % 100)
            setCtrl.cmdScreenLightSet(cmdManager, value: l) { st, light in
                if st == .success {
                    self.view.makeToast("屏幕亮度设置成功：\(l)",position: .center)
                }else{
                    self.view.makeToast("屏幕亮度设置失败\(st)",position: .center)
                }
            }
            break
        case 11:
            //TODO: 手电筒设置
            setCtrl.cmdFlashLightSet(cmdManager, status: arc4random() % 2 == 0  ? true : false) { status, isOn in
                if status == .success {
                    self.view.makeToast("手电筒设置成功",position: .center)
                }else{
                    self.view.makeToast("手电筒设置失败\(status)",position: .center)
                }
            }
            break
        case 12:
            let op = JLFindDeviceOperation()
            op.playWay = 0
            op.sound = 0x01
            op.timeout = 10
            cmdManager.mFindDeviceManager.cmdFindDevice(with: op)
            self.view.makeToast("找设备")
        case 13:
            makeSelectHandle { [weak self] in
                self?.navigationController?.pushViewController(TransportFileVC(), animated: true)
            }
        
        default:
            break
        }
    }
    
    
    
    func makeSelectHandle(_ block:@escaping ()->()){
        JL_RunSDK.sharedMe().mBleEntityM?.mCmdManager.cmdGetSystemInfo(.COMMON){ st, sn, dt in
            if let dev = JL_RunSDK.sharedMe().mBleEntityM?.mCmdManager.outputDeviceModel(){
                let alert = UIAlertController(title: "选择文件句柄", message: nil, preferredStyle: .actionSheet)
                for it in dev.cardArray{
                    if let value = it as? Int{
                        let action = UIAlertAction(title: JL_CardType(rawValue: UInt8(value))! .beString(), style: .default) { (ac) in
                            switch ac.title {
                            case "SD_0":
                                JL_RunSDK.sharedMe().mBleEntityM?.mCmdManager.mFileManager.setCurrentFileHandleType(.SD_0)
                            case "SD_1":
                                JL_RunSDK.sharedMe().mBleEntityM?.mCmdManager.mFileManager.setCurrentFileHandleType(.SD_1)
                            case "USB":
                                JL_RunSDK.sharedMe().mBleEntityM?.mCmdManager.mFileManager.setCurrentFileHandleType(.USB)
                            case "lineIn":
                                JL_RunSDK.sharedMe().mBleEntityM?.mCmdManager.mFileManager.setCurrentFileHandleType(.lineIn)
                            case "FLASH":
                                JL_RunSDK.sharedMe().mBleEntityM?.mCmdManager.mFileManager.setCurrentFileHandleType(.FLASH)
                            case "FLASH2":
                                JL_RunSDK.sharedMe().mBleEntityM?.mCmdManager.mFileManager.setCurrentFileHandleType(.FLASH2)
                                
                            default:
                                break
                            }
                            block()
                        }
                        alert.addAction(action)
                    }
                }
                alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
                
        }
    }
    
    //MARK: - 设置回调
    func publicSettingScreenLight(_ manager: JL_ManagerM, value light: UInt8) {
        self.view.makeToast("推送屏幕亮度:\(light)",duration: 4,position: .center);
    }
    
    func publicSettingFlashLight(_ manager: JL_ManagerM, value isOn: Bool) {
        self.view.makeToast("推送手电筒:\(isOn)",duration: 4,position: .center);
    }
    
}




fileprivate struct DateObj{
    var year:UInt16
    var month:UInt8
    var day:UInt8
    var hour:UInt8
    var minute:UInt8
    var second:UInt8
    static func make()->DateObj{
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        fmt.locale = Locale(identifier: "zh_CN")
        let str = fmt.string(from: Date())
        let arr = str.components(separatedBy: "-")
        return DateObj(year: UInt16(arr[0])!, month: UInt8(arr[1])!, day: UInt8(arr[2])!, hour: UInt8(arr[3])!, minute: UInt8(arr[4])!, second: UInt8(arr[5])!)
    }
    func beString()->String{
        return String(format: "%d-%d-%d %d:%d:%d", year,month,day,hour,minute,second)
    }
    
}

fileprivate extension JL_CardType{
    func beString()->String{
        switch self {
        case .FLASH:
            return "FLASH"
        case .SD_0:
            return "SD_0"
        case .USB:
            return "USB"
        case .SD_1:
            return "SD_1"
        case .lineIn:
            return "lineIn"
        case .FLASH2:
            return "FLASH2"
        @unknown default:
            return "未知"
        }
    }
}

