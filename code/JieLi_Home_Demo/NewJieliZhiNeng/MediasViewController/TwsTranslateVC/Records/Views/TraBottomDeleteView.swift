//
//  TraBottomDeleteView.swift
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2025/7/30.
//  Copyright © 2025 杰理科技. All rights reserved.
//

import UIKit

class TraBottomDeleteView: BasicView {
    private let iconImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "Theme.bundle/photo_icon_delete"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = R.Language.lan("delete")
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .center
        return label
    }()

    override func initUI() {
        super.initUI()
        setupViews()
    }

    private func setupViews() {
        backgroundColor = .white
        let stackView = UIStackView(arrangedSubviews: [iconImageView, titleLabel])
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.alignment = .center
        addSubview(stackView)

        stackView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview().inset(5)
            make.bottom.equalToSuperview().inset(bottomInset)
        }
        iconImageView.snp.makeConstraints { make in
            make.width.height.equalTo(24)
        }
    }
}
