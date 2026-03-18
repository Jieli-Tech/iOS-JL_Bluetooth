//
//  NRFFilterPopupView.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2025/12/11.
//

import UIKit
import SnapKit

/// 过滤弹窗组件：支持名称过滤与排序选择
class NRFFilterPopupView: UIView {
    enum SortOption { case rssiDesc, nameAsc }
    
    private let container = UIView()
    private let titleLabel = UILabel()
    private let textField = UITextField()
    private let segment = UISegmentedControl(items: ["RSSI", "Name"])
    private let confirmBtn = UIButton(type: .system)
    private let cancelBtn = UIButton(type: .system)
    
    var onConfirm: ((String?, SortOption) -> Void)?
    var onCancel: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.black.withAlphaComponent(0.4)
        container.backgroundColor = .systemBackground
        container.layer.cornerRadius = 12
        container.layer.masksToBounds = true
        addSubview(container)
        
        titleLabel.text = "Filter"
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textAlignment = .center
        container.addSubview(titleLabel)
        
        textField.placeholder = "Enter name keyword"
        textField.borderStyle = .roundedRect
        container.addSubview(textField)
        
        segment.selectedSegmentIndex = 0
        container.addSubview(segment)
        
        confirmBtn.setTitle("Confirm", for: .normal)
        confirmBtn.backgroundColor = .systemBlue
        confirmBtn.setTitleColor(.white, for: .normal)
        confirmBtn.layer.cornerRadius = 8
        container.addSubview(confirmBtn)
        
        cancelBtn.setTitle("Cancel", for: .normal)
        cancelBtn.backgroundColor = .systemGray4
        cancelBtn.setTitleColor(.label, for: .normal)
        cancelBtn.layer.cornerRadius = 8
        container.addSubview(cancelBtn)
        
        layoutUI()
        confirmBtn.addTarget(self, action: #selector(onConfirmTapped), for: .touchUpInside)
        cancelBtn.addTarget(self, action: #selector(onCancelTapped), for: .touchUpInside)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(onCancelTapped))
        addGestureRecognizer(tap)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func layoutUI() {
        container.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.left.right.equalToSuperview().inset(24)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(16)
            make.left.right.equalToSuperview().inset(16)
        }
        textField.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(40)
        }
        segment.snp.makeConstraints { make in
            make.top.equalTo(textField.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(16)
        }
        confirmBtn.snp.makeConstraints { make in
            make.top.equalTo(segment.snp.bottom).offset(16)
            make.left.equalToSuperview().inset(16)
            make.height.equalTo(40)
        }
        cancelBtn.snp.makeConstraints { make in
            make.top.equalTo(segment.snp.bottom).offset(16)
            make.right.equalToSuperview().inset(16)
            make.height.equalTo(40)
            make.left.equalTo(confirmBtn.snp.right).offset(12)
            make.width.equalTo(confirmBtn.snp.width)
            make.bottom.equalToSuperview().inset(16)
        }
    }
    
    @objc private func onConfirmTapped() {
        let keyword = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        if let k = keyword, k.count > 64 { return }
        let opt: SortOption = (segment.selectedSegmentIndex == 0) ? .rssiDesc : .nameAsc
        onConfirm?(keyword?.isEmpty == true ? nil : keyword, opt)
        removeFromSuperview()
    }
    
    @objc private func onCancelTapped() {
        onCancel?()
        removeFromSuperview()
    }
}

