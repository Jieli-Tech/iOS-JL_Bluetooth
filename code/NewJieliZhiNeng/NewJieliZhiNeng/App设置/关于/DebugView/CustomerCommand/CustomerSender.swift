//
//  CustomerSender.swift
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2022/10/14.
//  Copyright © 2022 杰理科技. All rights reserved.
//

import Foundation
import JL_BLEKit

typealias RestResponse = (_ status:JL_CMDStatus,_ sn:UInt8,_ data:Data?)->()

class CustomerSender: NSObject {
    
    /// this is the connect by user handler 
    var sender:JL_EntityM?;
    
    init(sender: JL_EntityM) {
        super.init()
        self.sender = sender
        self.addNote()
    }
    
    /// add note to receive device push data
    func addNote(){
        NotificationCenter.default.addObserver(self, selector: #selector(receiveDataFromDevice(note:)), name: NSNotification.Name(kJL_MANAGER_CUSTOM_DATA), object: nil)
    }
    
    
    /// send command to device
    /// - Parameter data: command
    func sendToDevice(data:Data){
        sender?.mCmdManager.mCustomManager.cmdCustomData(data) { status, sn, responseData in
            if(status == .success){
                print("send succeed")
            }else{
                print("send failed")
            }
            print("receive from device response:status:\(status.rawValue),sn:\(sn),responseData.length:\(String(describing: responseData?.count))")
        }
    }
    
    
    /// send reset command
    /// - Parameter block: reset callback status
    func sentResetCommand(_ block:@escaping RestResponse) {
        let array:[UInt8] = [0xA1]
        let data = Data(array)
        sender?.mCmdManager.mCustomManager.cmdCustomData(data, result: { status, sn, data in
            block(status,sn,data)
        })
    }
    
    /// send other command
    /// - Parameters:
    ///   - cmd: cmd like 0x01 ~ 0xFF
    ///   - block: command callback status
    func sentResetCommand(_ cmd:UInt8,_ block: RestResponse?) {
        var array:[UInt8] = []
        array.append(cmd)
        let data = Data(array)
        sender?.mCmdManager.mCustomManager.cmdCustomData(data, result: { status, sn, data in
            block?(status,sn,data)
        })
    }
    
    
    
    
    /// received data from device
    /// - Parameter note: data object
    @objc func receiveDataFromDevice(note:NSNotification){
        let data = note.object;
        print("receive from device:\(JL_Tools.dataChange(toString: data as! Data))")
        
    }

}
