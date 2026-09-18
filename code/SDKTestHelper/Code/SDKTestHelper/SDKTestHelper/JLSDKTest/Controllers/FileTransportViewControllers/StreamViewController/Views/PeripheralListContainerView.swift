//
//  PeripheralListContainerView.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2026/4/14.
//  Copyright © 2026 www.zh-jieli.com. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import JL_BLEKit

/// 设备在线外设功能列表容器
class PeripheralListContainerView: UIView {
    
    let refreshButton = UIButton(type: .system)
    private let titleLabel = UILabel()
    private let stackView = UIStackView()
    private let disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        self.backgroundColor = UIColor.compatibleSystemBackground
        self.layer.cornerRadius = 12
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.1
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowRadius = 4
        
        titleLabel.text = "在线外设功能列表"
        titleLabel.font = .boldSystemFont(ofSize: 16)
        self.addSubview(titleLabel)
        
        refreshButton.setTitle("刷新", for: .normal)
        self.addSubview(refreshButton)
        
        stackView.axis = .vertical
        stackView.spacing = 8
        self.addSubview(stackView)
        
        titleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(16)
        }
        
        refreshButton.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.trailing.equalToSuperview().inset(16)
        }
        
        stackView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.leading.trailing.bottom.equalToSuperview().inset(16)
        }
    }
    
    func bind(peripheralsDriver: Driver<[JLStreamPeripheralResponseModel]>) {
        peripheralsDriver
            .drive(onNext: { [weak self] models in
                guard let self = self else { return }
                self.stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
                
                if models.isEmpty {
                    let emptyLabel = UILabel()
                    emptyLabel.text = "暂无外设数据，请点击刷新"
                    emptyLabel.textColor = UIColor.compatibleSecondaryLabel
                    emptyLabel.textAlignment = .center
                    self.stackView.addArrangedSubview(emptyLabel)
                } else {
                    models.forEach { model in
                        let itemView = PeripheralItemView(model: model)
                        self.stackView.addArrangedSubview(itemView)
                    }
                }
            })
            .disposed(by: disposeBag)
    }
}
