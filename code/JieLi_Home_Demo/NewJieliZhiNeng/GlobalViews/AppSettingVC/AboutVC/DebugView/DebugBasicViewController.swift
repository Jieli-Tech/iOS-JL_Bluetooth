import UIKit
import SnapKit

class DebugBasicViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    var itemArray: [String] = [] {
        didSet {
            subTable?.reloadData()
        }
    }
    var subTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func initUI() {
        super.initUI()
        
        navigationView.title = "Debug"
        navigationView.leftBtn.addTarget(self, action: #selector(backBtnAction), for: .touchUpInside)
        
        subTable = UITableView()
        subTable.delegate = self
        subTable.dataSource = self
        subTable.rowHeight = 50
        subTable.tableFooterView = UIView()
        subTable.register(UITableViewCell.self, forCellReuseIdentifier: "localCellIdentify")
        view.addSubview(subTable)
        
        subTable.snp.makeConstraints { make in
            make.top.equalTo(navigationView.snp.bottom).offset(8)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    override func initData() {
        super.initData()
        itemArray = []
    }
    
    @objc func backBtnAction() {
        if let nav = navigationController, nav.viewControllers.count > 1 {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "localCellIdentify", for: indexPath)
        cell.textLabel?.text = itemArray[indexPath.row]
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
