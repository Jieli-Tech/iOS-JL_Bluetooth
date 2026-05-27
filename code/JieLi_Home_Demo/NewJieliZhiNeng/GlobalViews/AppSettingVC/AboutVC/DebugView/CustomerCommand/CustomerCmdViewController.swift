import UIKit
import SnapKit
import JL_BLEKit
import Combine

class CustomerCmdViewController: DebugBasicViewController, UITextFieldDelegate {
    
    private var sendTextFixed: UITextField!
    private var sendBtn: UIButton!
    private var clearBtn: UIButton!
    private var cmdTextLab: UITextView!
    private var logText: String = ""
    private var entity: JL_EntityM?
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationView.title = "自定义命令"
        logText = ""
        entity = JL_RunSDK.sharedMe().mBleEntityM
        stepUI()
        
        // 使用 Combine 接收自定义数据
        NotificationCenter.default.publisher(for: NSNotification.Name(kJL_MANAGER_CUSTOM_DATA))
            .sink { [weak self] note in
                guard let data = note.object as? Data else { return }
                let recStr = JL_Tools.dataChange(toString: data) ?? ""
                self?.addStrToLogText(recStr, sr: false)
            }
            .store(in: &cancellables)
    }
    
    private func stepUI() {
        subTable?.isHidden = true
        
        sendTextFixed = UITextField()
        sendTextFixed.delegate = self
        sendTextFixed.keyboardType = .asciiCapable
        sendTextFixed.returnKeyType = .done
        sendTextFixed.borderStyle = .roundedRect
        sendTextFixed.clearButtonMode = .whileEditing
        sendTextFixed.backgroundColor = UIColor(fromHexString: "#D7DADD")
        
        view.addSubview(sendTextFixed)
        sendTextFixed.snp.makeConstraints { make in
            make.top.equalTo(navigationView.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(60)
        }
        
        sendBtn = UIButton()
        view.addSubview(sendBtn)
        sendBtn.backgroundColor = .systemBlue
        sendBtn.layer.cornerRadius = 8
        sendBtn.layer.masksToBounds = true
        sendBtn.setTitle("Send", for: .normal)
        sendBtn.setTitleColor(.white, for: .normal)
        sendBtn.setTitleColor(.gray, for: .highlighted)
        sendBtn.addTarget(self, action: #selector(sendBtnAction), for: .touchUpInside)
        
        sendBtn.snp.makeConstraints { make in
            make.top.equalTo(sendTextFixed.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(40)
        }
        
        clearBtn = UIButton()
        view.addSubview(clearBtn)
        clearBtn.backgroundColor = .systemGreen
        clearBtn.layer.cornerRadius = 8
        clearBtn.layer.masksToBounds = true
        clearBtn.setTitle("Clear Cache Log", for: .normal)
        clearBtn.setTitleColor(.white, for: .normal)
        clearBtn.setTitleColor(.gray, for: .highlighted)
        clearBtn.addTarget(self, action: #selector(clearBtnAction), for: .touchUpInside)
        
        clearBtn.snp.makeConstraints { make in
            make.top.equalTo(sendBtn.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(40)
        }
        
        cmdTextLab = UITextView()
        cmdTextLab.font = UIFont.systemFont(ofSize: 13)
        cmdTextLab.textColor = .darkText
        cmdTextLab.isEditable = false
        view.addSubview(cmdTextLab)
        
        cmdTextLab.snp.makeConstraints { make in
            make.top.equalTo(clearBtn.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(textFixedClosed))
        view.addGestureRecognizer(tap)
    }
    
    @objc private func textFixedClosed() {
        sendTextFixed.endEditing(true)
    }
    
    @objc private func sendBtnAction() {
        if let text = sendTextFixed.text, !text.isEmpty {
            let data = JL_Tools.hex(toData: text) as? Data ?? Data()
            addStrToLogText(JL_Tools.dataChange(toString: data) ?? "", sr: true)
            
            entity?.mCmdManager.mCustomManager.cmdCustomData(data, result: { status, sn, resData in
                if status == .success {
                    JLLogManager.logLevel(.DEBUG, content: "发数成功...")
                } else {
                    JLLogManager.logLevel(.DEBUG, content: "发数失败~")
                }
            })
        } else {
            DFUITools.showText("Error for nothing to send", on: self.view, delay: 1.0)
        }
    }
    
    @objc private func clearBtnAction() {
        logText = ""
        cmdTextLab.text = logText
    }
    
    private func addStrToLogText(_ str: String, sr: Bool) {
        let typeStr = sr ? "send:" : "receive:"
        let fm = DateFormatter()
        fm.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateStr = fm.string(from: Date())
        
        var mstr = ""
        mstr.append("\n\(dateStr)\n\(typeStr)\(str)\n")
        mstr.append(logText)
        logText = mstr
        cmdTextLab.text = logText
        
        let range = NSRange(location: 0, length: 1)
        cmdTextLab.scrollRangeToVisible(range)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
}
