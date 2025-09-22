//
//  MediasFuncsView.swift
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2023/11/29.
//  Copyright © 2023 杰理科技. All rights reserved.
//

import UIKit

@objc enum MediasFuncType:UInt8 {
    case localBt = 0
    case usb = 1
    case sd = 2
    case fmtx = 3
    case fm = 4
    case linein = 5
    case light = 6
    case rtc = 7
    case searchDev = 8
    case network = 9
    case soundCard = 10
    case watch = 11
    case spdif = 12
    case pcServer = 13
    case translate = 14
    case record = 15
}

@objc protocol MediasFuncsPtl{
    func mediasHandleFuncSelect(_ model:MediasModel)
}

@objcMembers class MediasFuncsView: SwBasicView, JLDevPlayerCtrlDelegate, LanguagePtl {
    
    
    
    var collectView:UICollectionView!
    var flowLayout = UICollectionViewFlowLayout()
    var delegate:MediasFuncsPtl?
    private let itemsArray = BehaviorRelay<[MediasModel]>(value: [])
    private var allItems:[MediasModel] = []
    private var devCtrl = JLDevPlayerCtrl()
    private var currentItem:MediasModel?
    
    override func initUI() {
        super.initUI()
        self.backgroundColor = UIColor(fromHexString: "#F8FAFE")
        let w = UIScreen.main.bounds.width-40
        flowLayout.itemSize = CGSize(width: w/3, height: w/3)
        flowLayout.minimumLineSpacing = 4
        flowLayout.minimumInteritemSpacing = 4
        
        collectView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectView.showsVerticalScrollIndicator = false
        collectView.showsHorizontalScrollIndicator = false
        collectView.backgroundColor = UIColor.clear
        collectView.register(MediasFuncsCell.self, forCellWithReuseIdentifier: "MediasFuncsCell")
        self.addSubview(collectView)
        collectView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(10)
        }
        
        itemsArray.bind(to: collectView.rx.items(cellIdentifier: "MediasFuncsCell", cellType: MediasFuncsCell.self)) { index, model, cell in
            cell.configModel(model: model)
        }.disposed(by: disposeBag)
        
        addAll()
        
        collectView.rx.modelSelected(MediasModel.self).subscribe { [weak self](model) in
            for item in self?.itemsArray.value ?? []{
                item.isSelect = false
            }
            model.isSelect = true
            self?.currentItem = model
            let v = self?.itemsArray.value ?? []
            self?.itemsArray.accept(v)
            if model.type == .searchDev{
                self?.delegate?.mediasHandleFuncSelect(model)
                return
            }
            self?.delegate?.mediasHandleFuncSelect(model)
        }.disposed(by: disposeBag)
        
        
        JL_RunSDK.sharedMe().rx.observeWeakly(JL_EntityM.self, "mBleEntityM").subscribe(onNext: { [weak self] model in
            guard let cmdManager = model?.mCmdManager,let self = self else {
                self?.addAll()
                return
            }
            let model = cmdManager.getDeviceModel()
            self.updateWith(model: model)
            
            model.rx.observeWeakly(JL_FunctionCode.self, "currentFunc").subscribe { _ in
                self.updateWith(model: model)
            }.disposed(by: self.disposeBag)
            
            model.rx.observeWeakly(JLModelCardInfo.self, "cardInfo").subscribe { _ in
                self.updateWith(model: model)
            }.disposed(by: self.disposeBag)
        }).disposed(by: disposeBag)
        
        
        
    }
    
    
    override func initData() {
        super.initData()
        devCtrl.delegate = self
        LanguageCls.share().add(self)
    }
    
    func updateWith(model:JLModel_Device){
        var items:[MediasModel] = []
        
        for item in allItems{
            item.isSelect = false
        }
        //选择当前显示模式
        switch model.currentFunc {
            case .BT:
                allItems[0].isSelect = true
            case .MUSIC:
                cardStatusSel()
            case .RTC:
                allItems[7].isSelect = true
            case .LINEIN:
                allItems[5].isSelect = true
            case .FM:
                allItems[4].isSelect = true
            case .LIGHT:
                allItems[6].isSelect = true
            case .FMTX:
                allItems[3].isSelect = true
            case .COMMON:
                break
            case .EQ:
                break;
            case .SPDIF:
                allItems[12].isSelect = true
            case .pcServer:
                allItems[13].isSelect = true
            @unknown default:
                break
        }
        
        //选择显示内容
        //        if (model.deviceFuncs.isSupportEDR || model.function == 0){ //本地音乐（只要有蓝牙就支持）
        items.append(allItems[0])
        //        }
        if (model.deviceFuncs.isSupportUSB){
            if model.deviceFuncs.isShowOfflineFunc{
                items.append(allItems[1])
            }else{
                if model.cardInfo.usbOnline{
                    items.append(allItems[1])
                }
            }
        }
        if (model.deviceFuncs.isSupportSD0 || model.deviceFuncs.isSupportSD1){
            if model.deviceFuncs.isShowOfflineFunc{
                items.append(allItems[2])
            }else{
                if model.cardInfo.sd0Online || model.cardInfo.sd1Online{
                    items.append(allItems[2])
                }
            }
        }
        if model.deviceFuncs.isSupportDevFMTX{
            items.append(allItems[3])
        }
        if model.deviceFuncs.isSupportDevFm{
            items.append(allItems[4])
        }
        
        if model.deviceFuncs.isSupportDevLineIn{
            if model.deviceFuncs.isShowOfflineFunc{
                items.append(allItems[5])
            }else{
                if model.cardInfo.lineInOnline{
                    items.append(allItems[5])
                }
            }
        }
        
        if model.deviceFuncs.isSupportDevLight{
            items.append(allItems[6])
        }
        
        if model.deviceFuncs.isSupportDevRTC{
            items.append(allItems[7])
        }
        if model.searchType == .YES{
            items.append(allItems[8])
        }
        if model.deviceFuncs.isSupportNetRadio{
            items.append(allItems[9])
        }
        if model.karaokeType == .YES{
            items.append(allItems[10])
        }
        
        if model.deviceFuncs.isSupportSPDIF {
            items.append(allItems[12])
        }
        
        if model.deviceFuncs.isSupportPCServer {
            items.append(allItems[13])
        }
        
        if model.deviceFuncs.isSupportTranslate {
            items.append(allItems[14])
            items.append(allItems[15])
        }else{
            //FIXME: - 调试暂时强制加载翻译模式
//            items.append(allItems[14])
//            items.append(allItems[15])
        }
        
        itemsArray.accept(items)
    }
    
    private func addAll(){
        allItems.removeAll()
        let nameArr:[String] = ["multi_media_local","multi_media_usb_drive","multi_media_sd_card","multi_media_fm_launch","multi_media_fm_receive","multi_media_line_in","multi_media_light_settings","default_alarm_name","multi_media_search_device",                            "multi_media_net_radio","multi_media_sound_card","multi_media_watch","SPDIF","PC"]
        let imgArr:[String] = ["Theme.bundle/mul_icon_local_nor",
                               "Theme.bundle/mul_icon_usb_nor",
                               "Theme.bundle/mul_icon_sd_nor",
                               "Theme.bundle/mul_icon_fm_nor",
                               "Theme.bundle/mul_icon_fm2_nor",
                               "Theme.bundle/mul_icon_linein_nor",
                               "Theme.bundle/mul_icon_light_nol",
                               "Theme.bundle/mul_icon_clock_nol",
                               "Theme.bundle/mul_icon_lacation_nol",
                               "Theme.bundle/mul_icon_radio_nol",
                               "Theme.bundle/mul_icon_mic_nol",
                               "Theme.bundle/mul_icon_watch_nol",
                               "mul_icon_spdif",
                               "mul_icon_pc"
        ]
        for i in 0..<imgArr.count{
            allItems.append(MediasModel(title: R.Language.lan(nameArr[i]), img: R.Image.img(imgArr[i]), isSelect: false,type: MediasFuncType(rawValue: UInt8(i))!))
        }
        itemsArray.accept(allItems)
    }
    
    private func cardStatusSel(){
        guard let model = JL_RunSDK.sharedMe().mBleEntityM?.mCmdManager.getDeviceModel() else{return}
        switch model.currentCard{
            case .USB:
                allItems[1].isSelect = true
            case .SD_0:
                allItems[2].isSelect = true
            case .SD_1:
                allItems[2].isSelect = true
            case .FLASH:
                break
            case .lineIn:
                break
            case .FLASH2:
                break
            case .FLASH3:
                break
            @unknown default:
                break
        }
        
    }
    
    
}

extension MediasFuncsView{
    
    func languageChange() {
        addAll()
        guard let model = JL_RunSDK.sharedMe().mBleEntityM?.mCmdManager.getDeviceModel() else{return}
        self.updateWith(model: model)
    }
    func jlDevPlayerCtrl(_ ctrl: JLDevPlayerCtrl, playMode: UInt8) {
        
    }
    
    func jlDevPlayerCtrl(_ ctrl: JLDevPlayerCtrl, playStatus status: UInt8, currentCard card: UInt8, currentTime time: UInt32, tolalTime total: UInt32) {
        guard let model = JL_RunSDK.sharedMe().mBleEntityM?.mCmdManager.getDeviceModel() else{return}
        self.updateWith(model: model)
    }
    
    func jlDevPlayerCtrl(_ ctrl: JLDevPlayerCtrl, fileName name: String, currentClus clus: UInt32) {
        
    }
}

@objcMembers class MediasModel:NSObject{
    var title:String
    var img:UIImage
    var isSelect:Bool
    var type:MediasFuncType
    init(title: String, img: UIImage, isSelect: Bool,type:MediasFuncType) {
        self.title = title
        self.img = img
        self.isSelect = isSelect
        self.type = type
    }
}

class MediasFuncsCell: UICollectionViewCell {
    var imgView = UIImageView()
    var titleLab = MarqueeLabel()
    private let centerView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        centerView.backgroundColor = UIColor.white
        centerView.layer.cornerRadius = 8
        contentView.addSubview(centerView)
        
        centerView.addSubview(imgView)
        centerView.addSubview(titleLab)
        titleLab.textColor = UIColor(fromRGBAArray: [0,0,0,0.9])
        titleLab.font = R.Font.medium(14)
        titleLab.textAlignment = .center
        
        centerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
        }
        imgView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(15)
            make.width.height.equalTo(55)
        }
        titleLab.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(4)
            make.top.equalTo(imgView.snp.bottom)
            make.bottom.equalToSuperview()
        }
        
    }
    
    func configModel(model:MediasModel){
        imgView.image = model.img
        titleLab.text = model.title
        if model.isSelect{
            centerView.layer.shadowColor = UIColor(fromRGBAArray: [0,0,0,0.2]).cgColor
            centerView.layer.shadowOffset = CGSize(width: 0, height: 0)
            centerView.layer.shadowOpacity = 1
            centerView.layer.shadowRadius = 8
        }else{
            centerView.layer.shadowColor = UIColor.clear.cgColor
        }
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
