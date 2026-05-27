import Foundation
import JL_BLEKit
import Combine

typealias RestResponse = (_ status: JL_CMDStatus, _ sn: UInt8, _ data: Data?) -> Void

class CustomerSender: NSObject {
    
    var sender: JL_EntityM?
    private var cancellables = Set<AnyCancellable>()
    
    init(sender: JL_EntityM) {
        super.init()
        self.sender = sender
        self.addNote()
    }
    
    func addNote() {
        NotificationCenter.default.publisher(for: NSNotification.Name(kJL_MANAGER_CUSTOM_DATA))
            .sink { [weak self] note in
                self?.receiveDataFromDevice(note: note)
            }
            .store(in: &cancellables)
    }
    
    func sendToDevice(data: Data) {
        sender?.mCmdManager.mCustomManager.cmdCustomData(data) { status, sn, responseData in
            if status == .success {
                print("send succeed")
            } else {
                print("send failed")
            }
            print("receive from device response:status:\(status.rawValue),sn:\(sn),responseData.length:\(String(describing: responseData?.count))")
        }
    }
    
    func sentResetCommand(_ block: @escaping RestResponse) {
        let array: [UInt8] = [0xA1]
        let data = Data(array)
        sender?.mCmdManager.mCustomManager.cmdCustomData(data, result: { status, sn, data in
            block(status, sn, data)
        })
    }
    
    func sentResetCommand(_ cmd: UInt8, _ block: RestResponse?) {
        var array: [UInt8] = []
        array.append(cmd)
        let data = Data(array)
        sender?.mCmdManager.mCustomManager.cmdCustomData(data, result: { status, sn, data in
            block?(status, sn, data)
        })
    }
    
    private func receiveDataFromDevice(note: Notification) {
        guard let data = note.object as? Data else { return }
        print("receive from device:\(JL_Tools.dataChange(toString: data) ?? "")")
    }
}
