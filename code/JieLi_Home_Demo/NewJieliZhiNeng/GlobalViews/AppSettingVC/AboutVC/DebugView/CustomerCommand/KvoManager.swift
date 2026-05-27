import Foundation
import Combine
import JL_BLEKit

class KvoManager: NSObject {
    static let shared = KvoManager()
    private var cancellables = Set<AnyCancellable>()
    
    override private init() {
        super.init()
    }
    
    func startListen() {
        NotificationCenter.default.publisher(for: NSNotification.Name("EQ_MODE_CHANGE"))
            .sink { [weak self] note in
                self?.notificationAction(note)
            }
            .store(in: &cancellables)
        
        JLModel_Device.observeModelProperty("eqMode", action: #selector(addEqMode(_:)), own: self)
    }
    
    func requestEq() {
        guard let entity = JL_RunSDK.sharedMe().mBleEntityM else { return }
        entity.mCmdManager.cmdGetSystemInfo(JL_FunctionCode(rawValue: 0xff)!, selectionBit: 0x10) { status, sn, data in
            
        }
    }
    
    private func notificationAction(_ note: Notification) {
        if note.name.rawValue == "EQ_MODE_CHANGE" {
            guard let entity = JL_RunSDK.sharedMe().mBleEntityM else { return }
            let dev = entity.mCmdManager.outputDeviceModel()
            JLLogManager.logLevel(.DEBUG, content: "dev:\(dev.eqMode),dev.eqArray:\(String(describing: dev.eqArray))")
        }
    }
    
    @objc private func addEqMode(_ note: Notification) {
        if let obj = note.object {
            JLLogManager.logLevel(.DEBUG, content: "addNote:\(obj)")
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let device = object as? JLModel_Device {
            JLLogManager.logLevel(.DEBUG, content: "device.eqModel:\(device.eqMode)")
            JLLogManager.logLevel(.DEBUG, content: "device.eqArray:\(String(describing: device.eqArray))")
        }
    }
}
