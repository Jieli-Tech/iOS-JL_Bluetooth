import UIKit
import SnapKit
import Combine

class JLShareLogViewController: DebugBasicViewController {
    
    private var deleteView: TipsDeleteView!
    private var cancellables = Set<AnyCancellable>()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUIOverWrite()
    }
    
    override func initData() {
        super.initData()
        itemArray.removeAll()
        
        if let basicPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last {
            let fileManager = FileManager.default
            if let files = try? fileManager.contentsOfDirectory(atPath: basicPath) {
                for path in files where path.hasSuffix(".txt") {
                    let newPath = (basicPath as NSString).appendingPathComponent(path)
                    itemArray.append(newPath)
                }
            }
        }
        subTable?.reloadData()
    }
    
    private func initUIOverWrite() {
        navigationView.title = "log file"
        
        navigationView.rightBtn.isHidden = false
        navigationView.rightBtn.setTitle("clean log", for: .normal)
        navigationView.rightBtn.setTitleColor(.blue, for: .normal)
        navigationView.rightBtn.addTarget(self, action: #selector(removeAllLog), for: .touchUpInside)
        
        subTable?.isHidden = false
        
        if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
            deleteView = TipsDeleteView()
            window.addSubview(deleteView)
            deleteView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            deleteView.isHidden = true
            
            // 使用 Combine 替代 OC 中的 KVO
            deleteView.$isHidenStatus
                .sink { [weak self] isHidden in
                    if isHidden {
                        self?.initData()
                    }
                }
                .store(in: &cancellables)
        }
    }
    
    @objc private func removeAllLog() {
        deleteView?.isHidenStatus = false
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "localCellIdentify", for: indexPath)
        let path = itemArray[indexPath.row] as NSString
        cell.textLabel?.text = path.lastPathComponent
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = JLShareDetailViewController()
        vc.path = itemArray[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
}
