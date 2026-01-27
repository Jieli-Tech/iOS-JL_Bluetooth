//
//  ReconnectDevice.swift
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2025/6/12.
//  Copyright © 2025 杰理科技. All rights reserved.
//

import UIKit

@objcMembers class ReconnectDevice: NSObject {
    static func connectHistoryFirst() {
        DispatchQueue.main.asyncAfter(
            deadline: .now() + 1,
            execute: DispatchWorkItem(
                block: {
                    let list = SqliteManager.sharedInstance().checkOutAll()
                    guard let first = list.first else { return }
                    if JL_RunSDK.sharedMe().mBleEntityM?.mUUID == first.uuid { return }
                    JL_RunSDK.sharedMe().mBleMultiple.getEntityWithSearchUUID(first.uuid, searchStatus: true) { entity in
                        guard let entity = entity else { return }
                        JL_RunSDK.sharedMe().mBleMultiple.connectEntity(entity) { _ in
                        }
                    }
                })
        )
    }
}
