import UIKit
import SnapKit
import Combine

class TipsDeleteView: UIView {
    
    @Published var isHidenStatus: Bool = true {
        didSet {
            self.isHidden = isHidenStatus
        }
    }

    
    private let bgView = UIImageView()
    private let centerView = UIView()
    private let mainLab = UILabel()
    private let cancelBtn = UIButton()
    private let confirmBtn = UIButton()
    private let line0 = UIView()
    private let line1 = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initUI() {
        self.backgroundColor = .clear
        
        bgView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        addSubview(bgView)
        bgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        centerView.backgroundColor = .white
        centerView.layer.cornerRadius = 15
        centerView.layer.masksToBounds = true
        addSubview(centerView)
        centerView.snp.makeConstraints { make in
            make.height.equalTo(130)
            make.left.right.equalToSuperview().inset(45)
            make.centerY.equalToSuperview().offset(-70)
        }
        
        mainLab.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        mainLab.textColor = UIColor(fromHexString: "#242424")
        mainLab.text = "Weather delete log files or not?"
        mainLab.textAlignment = .center
        centerView.addSubview(mainLab)
        mainLab.snp.makeConstraints { make in
            make.top.equalTo(centerView.snp.top).offset(32)
            make.height.equalTo(32)
            make.centerX.equalToSuperview()
        }
        
        cancelBtn.setTitle("Cancel", for: .normal)
        cancelBtn.setTitleColor(UIColor(fromHexString: "#558CFF"), for: .normal)
        cancelBtn.setTitleColor(UIColor(fromHexString: "#A4A4A4"), for: .highlighted)
        cancelBtn.addTarget(self, action: #selector(cancelBtnAction), for: .touchUpInside)
        centerView.addSubview(cancelBtn)
        
        confirmBtn.setTitle("Delete", for: .normal)
        confirmBtn.setTitleColor(UIColor(fromHexString: "#558CFF"), for: .normal)
        confirmBtn.setTitleColor(UIColor(fromHexString: "#A4A4A4"), for: .highlighted)
        confirmBtn.addTarget(self, action: #selector(confirmBtnAction), for: .touchUpInside)
        centerView.addSubview(confirmBtn)
        
        cancelBtn.snp.makeConstraints { make in
            make.bottom.left.equalToSuperview()
            make.right.equalTo(confirmBtn.snp.left)
            make.height.equalTo(50)
            make.width.equalTo(confirmBtn.snp.width)
        }
        
        confirmBtn.snp.makeConstraints { make in
            make.bottom.right.equalToSuperview()
            make.left.equalTo(cancelBtn.snp.right)
            make.height.equalTo(50)
            make.width.equalTo(cancelBtn.snp.width)
        }
        
        line0.backgroundColor = UIColor(fromHexString: "#F5F5F5")
        centerView.addSubview(line0)
        line1.backgroundColor = UIColor(fromHexString: "#F5F5F5")
        centerView.addSubview(line1)
        
        line0.snp.makeConstraints { make in
            make.bottom.equalTo(cancelBtn.snp.top)
            make.left.right.equalToSuperview()
            make.height.equalTo(1)
        }
        
        line1.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.left.equalTo(cancelBtn.snp.right)
            make.height.equalTo(50)
            make.width.equalTo(1)
        }
    }
    
    @objc private func cancelBtnAction() {
        isHidenStatus = true
    }
    
    @objc private func confirmBtnAction() {
        if let basicPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last {
            let fileManager = FileManager.default
            if let files = try? fileManager.contentsOfDirectory(atPath: basicPath) {
                for path in files where path.hasSuffix(".txt") {
                    let newPath = (basicPath as NSString).appendingPathComponent(path)
                    try? fileManager.removeItem(atPath: newPath)
                }
            }
        }
        isHidenStatus = true
    }
}
