import UIKit
import SnapKit

class JLShareDetailViewController: DebugBasicViewController {
    
    var path: String = ""
    private var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func initUI() {
        super.initUI()
        
        navigationView.title = (path as NSString).lastPathComponent
        navigationView.rightBtn.isHidden = false
        navigationView.rightBtn.setTitle("share", for: .normal)
        navigationView.rightBtn.setTitleColor(.blue, for: .normal)
        navigationView.rightBtn.addTarget(self, action: #selector(shareLog), for: .touchUpInside)
        
        subTable?.isHidden = true
        
        textView = UITextView()
        if let data = FileManager.default.contents(atPath: path),
           let str = String(data: data, encoding: .utf8) {
            textView.text = str
        }
        textView.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        textView.backgroundColor = .white
        textView.textColor = UIColor(fromHexString: "#606060")
        textView.isEditable = false
        view.addSubview(textView)
        
        textView.snp.makeConstraints { make in
            make.top.equalTo(navigationView.snp.bottom).offset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
            make.left.right.equalToSuperview().inset(10)
        }
    }
    
    @objc private func shareLog() {
        guard let text = textView.text else { return }
        let activityVc = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        present(activityVc, animated: true, completion: nil)
    }
}
