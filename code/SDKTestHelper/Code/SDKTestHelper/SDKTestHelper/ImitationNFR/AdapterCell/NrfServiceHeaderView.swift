import UIKit
import SnapKit
import CoreBluetooth

/// Service 分组头视图
/// 展示 Service 名称/UUID 以及 PRIMARY/SECONDARY 标识
class NrfServiceHeaderView: UITableViewHeaderFooterView {
    private let titleLabel = UILabel()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .secondarySystemBackground
        titleLabel.font = .systemFont(ofSize: 13, weight: .medium)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 0
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(16)
            make.right.equalToSuperview().inset(16)
            make.top.bottom.equalToSuperview().inset(6)
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(_ service: CBService) {
        let name = "Service"
        let primary = service.isPrimary ? "PRIMARY SERVICE" : "SECONDARY SERVICE"
        titleLabel.text = "\(name)\nUUID: \(service.uuid.uuidString)\n\(primary)"
    }
}
