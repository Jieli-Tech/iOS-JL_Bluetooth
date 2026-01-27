//
//  SpdifPcViewModel.swift
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2024/10/17.
//  Copyright © 2024 杰理科技. All rights reserved.
//

import UIKit

@objcMembers class SpdifPcViewModel: NSObject {

    static let share = SpdifPcViewModel()
    let spdifModelListen = PublishSubject<JLModelSpdif>()
    let pcServerModelListen = PublishSubject<JLModelPCServer>()
    private let manager = JLSpdifPCManager()
    private let disposeBag = DisposeBag()
        
    override init() {
        super.init()
        manager.addDelegate(self)
    }
    
    
    deinit {
        manager.removeDelegate(self)
    }
    
    func getSpdifModel() -> Observable<JLModelSpdif> {
        return spdifModelListen
    }
    
    func getPcServerModel() -> Observable<JLModelPCServer> {
        return pcServerModelListen
    }
    
    func getPcServiceStatus(_ mgr:JL_EntityM? = nil){
        if mgr == nil {
            guard let mgr = JL_RunSDK.sharedMe().mBleEntityM?.mCmdManager else {return}
            manager.getPcServerStatus(mgr) { _, _, _ in
            }
        }else{
            manager.getPcServerStatus(mgr!.mCmdManager) { _, _, _ in
            }
        }
    }
    
    func getSpdifStatus(_ mgr:JL_EntityM? = nil){
        if mgr == nil {
            guard let mgr = JL_RunSDK.sharedMe().mBleEntityM?.mCmdManager else {return}
            manager.getSpdifStatus(mgr) { _, _, _ in
            }
        }else{
            manager.getSpdifStatus(mgr!.mCmdManager) { _, _, _ in
            }
        }
    }

    func setSpdifPlayStatus(){
        guard let mgr = JL_RunSDK.sharedMe().mBleEntityM?.mCmdManager else {return}
        let status = manager.spdifModel.playStatus
        manager.setSpdifPlayStatus(!status, manager: mgr) { status, _, _ in
            if status == .success {
                self.manager.spdifModel.playStatus = !self.manager.spdifModel.playStatus
                self.spdifModelListen.onNext(self.manager.spdifModel)
            }
        }
    }
    
    func setPCPlayStatus(){
        guard let mgr = JL_RunSDK.sharedMe().mBleEntityM?.mCmdManager else {return}
        let status = manager.pcServerModel.playStatus
        manager.setPcServerPlayStatus(!status, manager: mgr) { status, _, _ in
            if status == .success {
                self.manager.pcServerModel.playStatus = !self.manager.pcServerModel.playStatus
                self.pcServerModelListen.onNext(self.manager.pcServerModel)
            }
        }
    }
    
    func pcNextOrPrivious(_ type:JLPcServerOpType){
        guard let mgr = JL_RunSDK.sharedMe().mBleEntityM?.mCmdManager else {return}
        manager.setPcServerAction(type, manager: mgr, callBack: { status,  _, _ in
        })
    }
    
    func setSpdifAudioType(_ type:JLSpdifAudioType){
        guard let mgr = JL_RunSDK.sharedMe().mBleEntityM?.mCmdManager else {return}
        manager.setSpdifAction(type, manager: mgr, callBack: { status,  _, _ in
            if status == .success {
                self.manager.spdifModel.audioType = type
                self.spdifModelListen.onNext(self.manager.spdifModel)
            }
        })
    }
}


extension SpdifPcViewModel:JLSpdifPCProtocol {
    
    func updateSpdifModel(_ spdifModel: JLModelSpdif) {
        self.spdifModelListen.onNext(spdifModel)
    }
    
    func updatePcServerModel(_ pcServerModel: JLModelPCServer) {
        self.pcServerModelListen.onNext(pcServerModel)
    }
    
}

