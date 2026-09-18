//
//  SelectControls.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2026/8/19.
//  Copyright © 2026 www.zh-jieli.com. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift

private let chipFont = UIFont.systemFont(ofSize: 13)
private let chipHeight: CGFloat = 32

// MARK: - Chip Cell

final class ChipCell: UICollectionViewCell {
    let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = chipHeight / 2
        contentView.layer.masksToBounds = true
        contentView.layer.borderWidth = 1
        label.font = chipFont
        label.textAlignment = .center
        contentView.addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(text: String, selected: Bool) {
        label.text = text
        if selected {
            contentView.backgroundColor = UIColor.systemBlue
            contentView.layer.borderColor = UIColor.systemBlue.cgColor
            label.textColor = .white
        } else {
            contentView.backgroundColor = UIColor(red: 0.88, green: 0.92, blue: 0.98, alpha: 1.0)
            contentView.layer.borderColor = UIColor(red: 0.78, green: 0.85, blue: 0.95, alpha: 1.0).cgColor
            label.textColor = .darkGray
        }
    }
}

// MARK: - 内容自适应高度的 CollectionView

final class ContentSizedCollectionView: UICollectionView {
    override var intrinsicContentSize: CGSize { return contentSize }

    override func layoutSubviews() {
        super.layoutSubviews()
        if !bounds.size.equalTo(intrinsicContentSize) {
            invalidateIntrinsicContentSize()
        }
    }
}

// MARK: - 单行横向 chips

class ChipSelectView<T: Equatable & CustomStringConvertible>: BaseView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    private let titleLabel = UILabel()
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.sectionInset = .zero

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.showsVerticalScrollIndicator = false
        cv.alwaysBounceHorizontal = true
        cv.delegate = self
        cv.dataSource = self
        cv.register(ChipCell.self, forCellWithReuseIdentifier: "ChipCell")
        return cv
    }()

    private var items: [T] = []
    private(set) var selectedItem: T?

    var title: String? { didSet { titleLabel.text = title } }
    var defaultValue: T? { didSet { if let defaultValue { setSelected(defaultValue) } } }
    var onSelect: ((T) -> Void)?

    override func initUI() {
        titleLabel.font = .systemFont(ofSize: 14)
        titleLabel.textColor = .darkGray

        addSubview(titleLabel)
        addSubview(collectionView)

        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.width.equalTo(90)
        }

        collectionView.snp.makeConstraints { make in
            make.left.equalTo(titleLabel.snp.right).offset(8)
            make.right.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
            make.height.equalTo(chipHeight)
        }
    }

    func updateItems(_ newItems: [T]) {
        items = newItems
        collectionView.reloadData()
        if let selectedItem, items.contains(selectedItem) {
            setSelected(selectedItem)
        } else if let first = items.first {
            setSelected(first)
        }
    }

    func scrollToItem(_ item: T) { setSelected(item) }

    private func setSelected(_ item: T) {
        guard items.contains(item) else { return }
        selectedItem = item
        collectionView.reloadData()
    }

    // MARK: UICollectionView

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { items.count }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChipCell", for: indexPath) as! ChipCell
        let item = items[indexPath.item]
        cell.configure(text: item.description, selected: item == selectedItem)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let text = items[indexPath.item].description
        let w = (text as NSString).size(withAttributes: [.font: chipFont]).width + 24
        return CGSize(width: max(w, 44), height: chipHeight)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = items[indexPath.item]
        setSelected(item)
        onSelect?(item)
    }
}

// MARK: - 多行包裹 chips

class WrapChipSelectView<T: Equatable & CustomStringConvertible>: BaseView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    private let titleLabel = UILabel()
    private lazy var collectionView: ContentSizedCollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.sectionInset = .zero

        let cv = ContentSizedCollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.isScrollEnabled = false
        cv.delegate = self
        cv.dataSource = self
        cv.register(ChipCell.self, forCellWithReuseIdentifier: "ChipCell")
        return cv
    }()

    private var items: [T] = []
    private(set) var selectedItem: T?

    var title: String? { didSet { titleLabel.text = title } }
    var defaultValue: T? { didSet { if let defaultValue { setSelected(defaultValue) } } }
    var onSelect: ((T) -> Void)?

    override var intrinsicContentSize: CGSize {
        return CGSize(
            width: UIView.noIntrinsicMetric,
            height: titleLabel.intrinsicContentSize.height + 8 + collectionView.intrinsicContentSize.height
        )
    }

    override func initUI() {
        titleLabel.font = .systemFont(ofSize: 14)
        titleLabel.textColor = .darkGray

        addSubview(titleLabel)
        addSubview(collectionView)

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(12)
        }

        collectionView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(12)
            make.bottom.equalToSuperview()
        }
    }

    func updateItems(_ newItems: [T]) {
        items = newItems
        collectionView.reloadData()
        collectionView.layoutIfNeeded()
        invalidateIntrinsicContentSize()

        if let selectedItem, items.contains(selectedItem) {
            setSelected(selectedItem)
        } else if let first = items.first {
            setSelected(first)
        }
    }

    func scrollToItem(_ item: T) { setSelected(item) }

    private func setSelected(_ item: T) {
        guard items.contains(item) else { return }
        selectedItem = item
        collectionView.reloadData()
    }

    // MARK: UICollectionView

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { items.count }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChipCell", for: indexPath) as! ChipCell
        let item = items[indexPath.item]
        cell.configure(text: item.description, selected: item == selectedItem)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let text = items[indexPath.item].description
        let w = (text as NSString).size(withAttributes: [.font: chipFont]).width + 24
        return CGSize(width: max(w, 44), height: chipHeight)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = items[indexPath.item]
        setSelected(item)
        onSelect?(item)
    }
}

// MARK: - 分段选择器

class SegmentSelectView<T: Equatable & CustomStringConvertible>: BaseView {

    private let titleLabel = UILabel()
    private let segmentControl = UISegmentedControl()
    private var items: [T] = []
    private(set) var selectedItem: T?

    var title: String? { didSet { titleLabel.text = title } }
    var defaultValue: T? { didSet { if let defaultValue { setSelected(defaultValue) } } }
    var onSelect: ((T) -> Void)?

    override func initUI() {
        titleLabel.font = .systemFont(ofSize: 14)
        titleLabel.textColor = .darkGray

        segmentControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)

        addSubview(titleLabel)
        addSubview(segmentControl)

        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.width.equalTo(90)
        }

        segmentControl.snp.makeConstraints { make in
            make.left.equalTo(titleLabel.snp.right).offset(8)
            make.right.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
        }
    }

    func updateItems(_ newItems: [T]) {
        items = newItems
        segmentControl.removeAllSegments()
        for (index, item) in items.enumerated() {
            segmentControl.insertSegment(withTitle: item.description, at: index, animated: false)
        }

        if let selectedItem, let index = items.firstIndex(of: selectedItem) {
            segmentControl.selectedSegmentIndex = index
        } else if let first = items.first {
            setSelected(first)
        }
    }

    func scrollToItem(_ item: T) { setSelected(item) }

    private func setSelected(_ item: T) {
        guard let index = items.firstIndex(of: item) else { return }
        selectedItem = item
        segmentControl.selectedSegmentIndex = index
    }

    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        guard index >= 0, index < items.count else { return }
        let item = items[index]
        selectedItem = item
        onSelect?(item)
    }
}
