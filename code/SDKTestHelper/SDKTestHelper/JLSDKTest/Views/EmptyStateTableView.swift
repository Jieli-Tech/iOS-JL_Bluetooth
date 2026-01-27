//
//  EmptyStateTableView.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2025/6/17.
//  Copyright © 2025 www.zh-jieli.com. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class EmptyStateTableView: UITableView {
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let emptyStateLabel = UILabel()
    
    /// 空状态视图（可自定义）
    var emptyBackgroundView: UIView? {
        didSet {
            emptyBackgroundView?.translatesAutoresizingMaskIntoConstraints = false
            reloadEmptyState()
        }
    }
    
    /// 空状态文本
    var emptyStateLabelText: String? {
        get { emptyStateLabel.text }
        set { emptyStateLabel.text = newValue }
    }
    
    /// 绑定数据源是否为空
    var isEmpty: Binder<Bool> {
        return Binder(self) { tableView, isEmpty in
            isEmpty ? tableView.showEmptyView() : tableView.hideEmptyView()
        }
    }
    
    // MARK: - Initialization
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = .clear
        tableFooterView = UIView() // 去除多余分割线
    }
    
    // MARK: - Empty State Management
    private func showEmptyView() {
        if backgroundView == nil {
            backgroundView = emptyBackgroundView ?? createDefaultEmptyView()
            layoutEmptyView()
        }
    }
    
    private func hideEmptyView() {
        backgroundView = nil
    }
    
    private func reloadEmptyState() {
        // 留给外部手动触发使用
        showEmptyView()
    }
    
    private func layoutEmptyView() {
        guard let backgroundView = backgroundView else { return }
        
        backgroundView.snp.remakeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-40)
            make.width.equalToSuperview().inset(20)
            make.height.greaterThanOrEqualTo(200)
        }
    }
    
    
    
    // MARK: - Default Empty View
    private func createDefaultEmptyView() -> UIView {
        let container = UIView()
        
        let imageView = UIImageView(image: UIImage(systemName: "list.bullet"))
        imageView.tintColor = .random()
        imageView.contentMode = .scaleAspectFit
    
        emptyStateLabel.text = "暂无数据"
        emptyStateLabel.font = .systemFont(ofSize: 14)
        emptyStateLabel.textColor = .systemGray
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.numberOfLines = 0
        emptyStateLabel.adjustsFontSizeToFitWidth = true
        
        // 使用SnapKit布局
        container.addSubview(imageView)
        container.addSubview(emptyStateLabel)
        
        imageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.height.equalTo(70)
        }
        
        emptyStateLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(12)
            make.bottom.equalToSuperview().inset(12)
        }
        
        return container
    }
    
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutEmptyView()
    }
}
