import UIKit

class DebugFuncsViewController: DebugBasicViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        itemArray = ["share log", "customer command", "request EQ", "彩屏舱"]
        navigationView.title = "Debug Helper"
        KvoManager.shared.startListen()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row {
        case 0:
            let vc = JLShareLogViewController()
            navigationController?.pushViewController(vc, animated: true)
        case 1:
            let vc = CustomerCmdViewController()
            navigationController?.pushViewController(vc, animated: true)
        case 2:
            let eq = JL_RunSDK.sharedMe().mBleEntityM?.mCmdManager.mSystemEQ
                eq?.cmdGet({ status, model in })
            if let mBleEntityM = JL_RunSDK.sharedMe().mBleEntityM {
                let adv = JLDevicesAdv.advertData(toModel: mBleEntityM.mAdvData)
                adv?.logProperties()
            }
        case 3:
            let vc = ColorfulBoxVC()
            navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }
    }
}
