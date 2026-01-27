import UIKit
import SnapKit
import CoreBluetooth

/// 特征展示 Cell
/// 展示特征基本信息、写入按钮、订阅按钮，以及红框区域显示最近一次 notify 内容
class NrfCharacteristicCell: UITableViewCell {
    private let titleLabel = UILabel()
    private let propLabel = UILabel()
    private let readBtn = UIButton(type: .system)
    private let writeBtn = UIButton(type: .system)
    private let notifyBtn = UIButton(type: .system)
    private let valueLabel = UILabel()

    var onReadTapped: (() -> Void)?
    var onWriteTapped: (() -> Void)?
    var onToggleNotify: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.backgroundColor = .systemBackground

        titleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 0
        contentView.addSubview(titleLabel)

        propLabel.font = .systemFont(ofSize: 12)
        propLabel.textColor = .secondaryLabel
        propLabel.numberOfLines = 0
        contentView.addSubview(propLabel)

        readBtn.setTitle("Read", for: .normal)
        readBtn.setTitleColor(.white, for: .normal)
        readBtn.backgroundColor = .systemIndigo
        readBtn.layer.cornerRadius = 6
        readBtn.addTarget(self, action: #selector(onRead), for: .touchUpInside)
        contentView.addSubview(readBtn)

        writeBtn.setTitle("Write", for: .normal)
        writeBtn.setTitleColor(.white, for: .normal)
        writeBtn.backgroundColor = .systemBlue
        writeBtn.layer.cornerRadius = 6
        writeBtn.addTarget(self, action: #selector(onWrite), for: .touchUpInside)
        contentView.addSubview(writeBtn)

        notifyBtn.setTitle("Subscribe", for: .normal)
        notifyBtn.setTitleColor(.white, for: .normal)
        notifyBtn.backgroundColor = .systemTeal
        notifyBtn.layer.cornerRadius = 6
        notifyBtn.addTarget(self, action: #selector(onNotify), for: .touchUpInside)
        contentView.addSubview(notifyBtn)


        valueLabel.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        valueLabel.textColor = .label
        valueLabel.numberOfLines = 0
        contentView.addSubview(valueLabel)
        layoutUI()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func layoutUI() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(8)
            make.left.equalToSuperview().inset(16)
            make.right.lessThanOrEqualToSuperview().inset(16)
        }
        propLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.left.equalTo(titleLabel)
            make.right.lessThanOrEqualToSuperview().inset(16)
        }
        
        let stack = UIStackView(arrangedSubviews: [readBtn, writeBtn, notifyBtn])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        contentView.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.top.equalTo(propLabel.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(28)
        }
        
        valueLabel.snp.makeConstraints { make in
            make.top.equalTo(stack.snp.bottom).offset(8)
            make.left.equalToSuperview().inset(8)
            make.right.equalToSuperview().inset(8)
            make.bottom.equalToSuperview().inset(8)
        }
    }

    @objc private func onRead() { onReadTapped?() }
    @objc private func onWrite() { onWriteTapped?() }
    @objc private func onNotify() { onToggleNotify?() }

    func configure(_ ch: CBCharacteristic, notifyText: String?, isNotifying: Bool) {
        let name = "Characteristic"
        titleLabel.text = "\(name)\nUUID: \(ch.uuid.uuidString)"
        propLabel.text = propertiesString(ch.properties)
        
        readBtn.isHidden = !ch.properties.contains(.read)
        writeBtn.isHidden = !(ch.properties.contains(.write) || ch.properties.contains(.writeWithoutResponse))
        notifyBtn.isHidden = !ch.properties.contains(.notify)
        notifyBtn.backgroundColor = isNotifying ? .systemGreen : .systemTeal
        
        valueLabel.text = notifyText ?? ""
    }

    private func propertiesString(_ p: CBCharacteristicProperties) -> String {
        var arr: [String] = []
        if p.contains(.read) { arr.append("Read") }
        if p.contains(.write) { arr.append("Write") }
        if p.contains(.writeWithoutResponse) { arr.append("WriteNoRsp") }
        if p.contains(.notify) { arr.append("Notify") }
        if p.contains(.indicate) { arr.append("Indicate") }
        return "Properties: " + arr.joined(separator: "/")
    }
}
