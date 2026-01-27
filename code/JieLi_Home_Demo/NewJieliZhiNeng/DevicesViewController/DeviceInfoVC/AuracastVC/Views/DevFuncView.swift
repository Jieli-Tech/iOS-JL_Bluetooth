//
//  DevFuncView.swift
//  JieLiAuracastAssistant
//
//  Created by EzioChan on 2024/9/12.
//

import UIKit
import SnapKit

private struct DevFuncViewModel {
    var title: String
    var secondTitle: String?
    var icon: UIImage
}

private class DevFuncViewCell: UICollectionViewCell {
    private let nameLabel = UILabel()
    private let secondLabel = UILabel()
    private let iconView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        layer.cornerRadius = 8
        layer.masksToBounds = true

        contentView.addSubview(nameLabel)
        contentView.addSubview(secondLabel)
        contentView.addSubview(iconView)
        nameLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        nameLabel.textColor = RResources.color.fontBackText242424()
        nameLabel.adjustsFontSizeToFitWidth = true

        secondLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        secondLabel.textColor = .eHex("#242424", alpha: 0.5)
        secondLabel.adjustsFontSizeToFitWidth = true
        secondLabel.isHidden = true

        nameLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().inset(24)
            make.right.equalTo(iconView.snp.left).offset(-8)
        }
        secondLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(10)
            make.left.equalToSuperview().inset(24)
            make.right.equalTo(iconView.snp.left).offset(-8)
        }
        iconView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(21)
            make.width.height.equalTo(24)
        }
    }

    func setData(_ model: DevFuncViewModel) {
        nameLabel.text = model.title
        secondLabel.text = model.secondTitle
        iconView.image = model.icon
        if model.secondTitle == nil {
            secondLabel.isHidden = true
            nameLabel.snp.remakeConstraints { make in
                make.centerY.equalToSuperview()
                make.left.equalToSuperview().inset(24)
                make.right.equalTo(iconView.snp.left).offset(-8)
            }
        } else {
            secondLabel.isHidden = false
            nameLabel.snp.remakeConstraints { make in
                make.centerY.equalToSuperview().offset(-10)
                make.left.equalToSuperview().inset(24)
                make.right.equalTo(iconView.snp.left).offset(-8)
            }
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class DevFuncView: BasicView {
    private var subCollectView: UICollectionView!
    private let itemsList = BehaviorRelay<[DevFuncViewModel]>(value: [])
    var handleFuncAction: ((_ index: Int) -> Void)?

    override func initUI() {
        super.initUI()
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 8
        flowLayout.minimumInteritemSpacing = 0
        // 减去两边边距和中间间距，按照 UI 分布一行两个除以二
        let width = (UIScreen.main.bounds.size.width) / 2 - 16
        flowLayout.itemSize = CGSize(width: width, height: 64)
        subCollectView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        subCollectView.backgroundColor = .clear
        subCollectView.showsVerticalScrollIndicator = false
        subCollectView.register(DevFuncViewCell.self, forCellWithReuseIdentifier: "DevFuncViewCell")
        addSubview(subCollectView)
        subCollectView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        itemsList.bind(to: subCollectView.rx.items(cellIdentifier: "DevFuncViewCell",
                                                   cellType: DevFuncViewCell.self)) { _, element, cell in

            cell.setData(element)

        }.disposed(by: disposeBag)

        subCollectView.rx.itemSelected.subscribe { [weak self] index in
            guard let self = self else { return }
            if let handle = self.handleFuncAction {
                handle(index.element?.row ?? 0)
            }
        }.disposed(by: disposeBag)
    }

    override func initData() {
        super.initData()
        // FIXME: 模拟数据
        var list = [DevFuncViewModel]()
        list.append(DevFuncViewModel(title: "快捷操作", icon: RResources.image.function_icon_click()!))
        list.append(DevFuncViewModel(title: "工作模式", secondTitle: "游戏模式", icon: RResources.image.function_icon_mode()!))
        list.append(DevFuncViewModel(title: "麦克风", icon: RResources.image.function_icon_mic()!))
        list.append(DevFuncViewModel(title: "闪灯设置", icon: RResources.image.function_icon_light()!))
        list.append(DevFuncViewModel(title: "双设备连接", icon: RResources.image.function_icon_connection()!))
        list.append(DevFuncViewModel(title: "固件升级", icon: RResources.image.function_icon_update()!))
        itemsList.accept(list)
    }
}
