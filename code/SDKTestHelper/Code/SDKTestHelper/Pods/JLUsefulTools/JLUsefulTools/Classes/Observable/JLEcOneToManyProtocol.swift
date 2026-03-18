//
//  JLEcOneToManyProtocol.swift
//  JLUsefulTools
//
//  Created by EzioChan on 2021/8/31.
//

import Foundation

@objc open class Onetomany: NSObject {
    @objc public var hashObjc: NSHashTable = NSHashTable<AnyObject>(options: .weakMemory)
    private var lock: NSLock = .init()
    @objc public func add(_ any: AnyObject) {
        lock.lock()
        if !hashObjc.contains(any) {
            hashObjc.add(any)
        }
        lock.unlock()
    }

    @objc public func remove(_ any: AnyObject) {
        DispatchQueue.global().async {
            self.lock.lock()
            if self.hashObjc.contains(any) {
                self.hashObjc.remove(any)
            }
            self.lock.unlock()
        }
    }

    @objc public func remoeAll() {
        lock.lock()
        hashObjc.removeAllObjects()
        lock.unlock()
    }

    @objc public func startBroadcast(_ block: @escaping (AnyObject) -> Void) {
        lock.lock()
        for item in hashObjc.allObjects {
            block(item)
        }
        lock.unlock()
    }
}
