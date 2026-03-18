//
//  SelectView.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2025/2/12.
//  Copyright © 2025 www.zh-jieli.com. All rights reserved.
//

import UIKit

class DropdownView<T: CustomStringConvertible & Equatable>: BaseView, UIPickerViewDelegate, UIPickerViewDataSource {
    private let titleLabel = UILabel() // 左侧标题
    private let pickerView = UIPickerView() // 选择器
    private let dropMaskView = UIView()

    private let items = BehaviorRelay<[T]>(value: [])
    private let selectedItem = BehaviorRelay<T?>(value: nil) // 当前选中项

    var onSelect: ((T) -> Void)?

    /// 设置类别标题
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }

    /// 设置默认选中的值（外部可指定）
    var defaultValue: T? {
        didSet {
            if let defaultValue = defaultValue, let index = items.value.firstIndex(of: defaultValue) {
                pickerView.selectRow(index, inComponent: 0, animated: false)
                selectedItem.accept(defaultValue)
            }
        }
    }

    override func initUI() {
        super.initUI()

        titleLabel.font = .systemFont(ofSize: 14)
        titleLabel.textColor = .darkGray

        pickerView.delegate = self
        pickerView.dataSource = self

        addSubview(titleLabel)
        addSubview(pickerView)

        addSubview(dropMaskView)

        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.equalTo(pickerView)
            make.width.equalTo(80)
        }

        pickerView.snp.makeConstraints { make in
            make.left.equalTo(titleLabel.snp.right).offset(8)
            make.right.equalToSuperview()
            make.top.bottom.equalToSuperview()
        }

        dropMaskView.backgroundColor = .eHex("#000000", alpha: 0.6)
        dropMaskView.layer.cornerRadius = 8
        dropMaskView.layer.masksToBounds = true

        dropMaskView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        dropMaskView.isHidden = true

        bindPickerView()
    }

    private func bindPickerView() {
        items.subscribe(onNext: { [weak self] _ in
            self?.pickerView.reloadAllComponents()
            self?.restoreDefaultSelection() // 更新数据时，确保默认值仍然有效
        }).disposed(by: disposeBag)
    }

    func updateItems(_ newItems: [T]) {
        items.accept(newItems)
        restoreDefaultSelection() // 确保 Picker 选中正确的默认值
    }
    
    func scrollToItem(_ item: T) {
        if let index = items.value.firstIndex(of: item) {
            pickerView.selectRow(index, inComponent: 0, animated: false)
        }
    }

    func show(_ isShow: Bool) {
        dropMaskView.isHidden = isShow
    }

    /// 选中默认值
    private func restoreDefaultSelection() {
        if let defaultValue = selectedItem.value, let index = items.value.firstIndex(of: defaultValue) {
            pickerView.selectRow(index, inComponent: 0, animated: false)
        } else if let firstItem = items.value.first {
            pickerView.selectRow(0, inComponent: 0, animated: false)
            selectedItem.accept(firstItem)
        }
    }

    // MARK: - UIPickerView Delegate & DataSource

    func numberOfComponents(in _: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_: UIPickerView, numberOfRowsInComponent _: Int) -> Int {
        return items.value.count
    }

    func pickerView(_: UIPickerView, viewForRow row: Int, forComponent _: Int, reusing view: UIView?) -> UIView {
        let label = view as? UILabel ?? UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14) // 设置字体大小
        label.text = items.value[row].description
        label.adjustsFontSizeToFitWidth = true
        return label
    }

    func pickerView(_: UIPickerView, didSelectRow row: Int, inComponent _: Int) {
        let selectedValue = items.value[row]
        selectedItem.accept(selectedValue)
        onSelect?(selectedValue)
    }
}
