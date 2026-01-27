//
//  CalendarPickerView.swift
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2025/5/28.
//  Copyright © 2025 杰理科技. All rights reserved.
//

import UIKit

// MARK: - 日期 Cell

private class CalendarDateCell: UICollectionViewCell {
    static let reuseId = "CalendarDateCell"
    let dateLabel: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .eHex("#000000", alpha: 0.3)
        lbl.textAlignment = .center
        lbl.font = R.Font.medium(15)
        lbl.adjustsFontSizeToFitWidth = true
        return lbl
    }()

    let bgImgv = UIImageView()
    override init(frame: CGRect) {
        super.init(frame: frame)
        bgImgv.backgroundColor = .eHex("#7657EC")
        bgImgv.layer.cornerRadius = 15
        bgImgv.layer.masksToBounds = true
        bgImgv.isHidden = true

        contentView.addSubview(bgImgv)
        contentView.addSubview(dateLabel)
        dateLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        bgImgv.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(30)
        }
    }

    func config(dayText: String? = nil, isSelected: Bool = false, hasData: Bool = false, isToday: Bool = false) {
        dateLabel.text = dayText
        bgImgv.isHidden = true
        bgImgv.backgroundColor = .eHex("#F0F0F0")
        dateLabel.textColor = .eHex("#000000", alpha: 0.3)
        if hasData {
            dateLabel.textColor = .eHex("#000000", alpha: 0.9)
        }
        if isToday && dateLabel.text?.count ?? 0 > 0 {
            bgImgv.isHidden = false
            bgImgv.backgroundColor = .eHex("#F0F0F0")
            dateLabel.textColor = .eHex("#000000", alpha: 0.9)
        }
        if isSelected && dateLabel.text?.count ?? 0 > 0 {
            bgImgv.isHidden = false
            bgImgv.backgroundColor = .eHex("#7657EC")
            dateLabel.textColor = .white
        } else {
            bgImgv.isHidden = true
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError() }
}

// MARK: - CalendarPickerView

class CalendarPickerView: BasicView {
    // MARK: UI Components

    let closeBtn = UIButton()
    var hasDataDates: [Date] = [] {
        didSet {
            collectionView.reloadData()
        }
    }

    private let header: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()

    private let prevBtn = UIButton()
    private let nextBtn = UIButton()
    private let titleLabel: UILabel = {
        let lab = UILabel()
        lab.textAlignment = .center
        lab.textColor = .eHex("#000000", alpha: 0.9)
        lab.font = R.Font.medium(14)
        return lab
    }()

    private let weekStack = UIStackView()
    private lazy var collectionView: UICollectionView = {
        // 初始化 CollectionView
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()

    // MARK: Data & Rx

    private let daysRelay = BehaviorRelay<[Date?]>(value: [])
    private var currentMonth = Date().firstDayOfMonth
    public var selectedDate = BehaviorRelay<Date>(value: Date())

    // MARK: UI 构建

    override func initUI() {
        super.initUI()
        backgroundColor = .white
        layer.cornerRadius = 24
        // header
        addSubview(header)
        header.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(50)
        }
        prevBtn.setImage(R.Image.img("icon_date_last_nor"), for: .normal)
        nextBtn.setImage(R.Image.img("icon_date_next_nor"), for: .normal)
        closeBtn.setImage(R.Image.img("icon_close_24"), for: .normal)

        header.addSubview(prevBtn)
        header.addSubview(nextBtn)
        header.addSubview(titleLabel)
        header.addSubview(closeBtn)
        prevBtn.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.width.height.equalTo(44)
            $0.right.equalTo(titleLabel.snp.left).offset(-10)
        }
        nextBtn.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.width.height.equalTo(44)
            $0.left.equalTo(titleLabel.snp.right).offset(10)
        }
        closeBtn.snp.makeConstraints {
            $0.right.equalToSuperview()
            $0.centerY.equalTo(titleLabel)
            $0.width.height.equalTo(44)
        }
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview()
        }

        // 星期标题
        weekStack.axis = .horizontal
        weekStack.distribution = .fillEqually
        let dateType = [
            R.Language.lan("alarm_repeat_sun"),
            R.Language.lan("alarm_repeat_mon"),
            R.Language.lan("alarm_repeat_tue"),
            R.Language.lan("alarm_repeat_wed"),
            R.Language.lan("alarm_repeat_thu"),
            R.Language.lan("alarm_repeat_fri"),
            R.Language.lan("alarm_repeat_sat"),
        ]
        for item in dateType {
            let lbl = UILabel()
            lbl.font = R.Font.medium(14)
            lbl.text = item
            lbl.textColor = .eHex("#000000", alpha: 0.3)
            lbl.textAlignment = .center
            lbl.adjustsFontSizeToFitWidth = true
            weekStack.addArrangedSubview(lbl)
        }
        addSubview(weekStack)
        weekStack.snp.makeConstraints { make in
            make.top.equalTo(header.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(30)
        }

        // 日期网格
        addSubview(collectionView)
        collectionView.register(CalendarDateCell.self, forCellWithReuseIdentifier: CalendarDateCell.reuseId)
        collectionView.backgroundColor = .clear
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(weekStack.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
    }

    // MARK: Data & 绑定

    override func initData() {
        bindActions()
        loadMonth(currentMonth)
    }

    private func bindActions() {
        // 上月
        prevBtn.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let s = self else { return }
                s.currentMonth = s.currentMonth.adding(months: -1)
                s.loadMonth(s.currentMonth)
            })
            .disposed(by: disposeBag)
        // 下月
        nextBtn.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let s = self else { return }
                let target = s.currentMonth.adding(months: 1)
                let nowMonth = Date().firstDayOfMonth
                // 不允许进入未来月份
                guard target <= nowMonth else { return }
                s.currentMonth = target
                s.loadMonth(s.currentMonth)
            })
            .disposed(by: disposeBag)

        daysRelay
            .bind(to: collectionView.rx.items(
                cellIdentifier: CalendarDateCell.reuseId,
                cellType: CalendarDateCell.self
            )) {
                _,
                    dateOpt,
                    cell in
                if let date = dateOpt {
                    let day = Calendar.current.component(.day, from: date)
                    cell.dateLabel.text = "\(day)"
                    cell.isUserInteractionEnabled = true
                    cell.config(
                        dayText: "\(day)",
                        isSelected: date.isSameDate(self.selectedDate.value),
                        hasData: self.hasDataAt(date: date),
                        isToday: date.isSameDate(Date())
                    )
                } else {
                    cell.dateLabel.text = nil
                    cell.bgImgv.isHidden = true
                    cell.isUserInteractionEnabled = false
                }
            }
            .disposed(by: disposeBag)

        // 选中事件
        collectionView.rx.itemSelected
            .withLatestFrom(daysRelay) { $1[$0.item] }
            .compactMap { $0 }
            .bind(to: selectedDate)
            .disposed(by: disposeBag)

        collectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)
    }

    private func hasDataAt(date: Date) -> Bool {
        for item in hasDataDates {
            if item.isSameDate(date) {
                return true
            }
        }
        return false
    }

    // 更新导航按钮状态：当展示到当前月份时，禁用“下月”按钮
    private func updateNavigationAvailability() {
        let atCurrentMonth = currentMonth.isSameMonth(Date())
        nextBtn.isEnabled = !atCurrentMonth
        nextBtn.alpha = nextBtn.isEnabled ? 1.0 : 0.4
        // 如需隐藏可改为：nextBtn.isHidden = atCurrentMonth
    }

    private func loadMonth(_ month: Date) {
        titleLabel.text = month.toString("yyyy-MM")

        var arr: [Date?] = []
        // 前面空格
        for _ in 1 ..< month.weekdayOfFirst {
            arr.append(nil)
        }
        // 当月每一天
        let range = month.numberOfDaysInMonth
        for d in 1 ... range {
            var comp = Calendar.current.dateComponents([.year, .month], from: month)
            comp.day = d
            arr.append(Calendar.current.date(from: comp))
        }
        daysRelay.accept(arr)

        // 刷新导航按钮状态
        updateNavigationAvailability()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension CalendarPickerView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ cv: UICollectionView,
                        layout _: UICollectionViewLayout,
                        sizeForItemAt _: IndexPath) -> CGSize
    {
        let w = cv.bounds.width / 7.0
        return CGSize(width: w, height: w)
    }
}

class AlertCalendarPickerView: BasicView {
    private let content = UIView()
    let calendar = CalendarPickerView(frame: .zero)
    override func initUI() {
        super.initUI()
        backgroundColor = .clear
        content.backgroundColor = .eHex("#000000", alpha: 0.3)

        calendar.backgroundColor = .white
        calendar.layer.cornerRadius = 12
        calendar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        calendar.layer.masksToBounds = true

        addSubview(content)
        addSubview(calendar)
        content.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        calendar.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(400)
        }
        let tapges = UITapGestureRecognizer(target: self, action: #selector(didClose))
        content.addGestureRecognizer(tapges)
    }

    override func initData() {
        super.initData()

        calendar.closeBtn.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.isHidden = true
            })
            .disposed(by: disposeBag)
    }

    @objc func didClose() {
        isHidden = true
    }
}
