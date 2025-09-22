//
//  CalendarPickerView.swift
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2025/5/28.
//  Copyright © 2025 杰理科技. All rights reserved.
//

import UIKit

// MARK: - 日期工具扩展

private extension Date {
    /// 当月第一天
    var firstDayOfMonth: Date {
        let comp = Calendar.current.dateComponents([.year, .month], from: self)
        return Calendar.current.date(from: comp)!
    }

    /// 当月天数
    var numberOfDaysInMonth: Int {
        Calendar.current.range(of: .day, in: .month, for: self)!.count
    }

    /// 星期偏移（周日=1，周一=2...）
    var weekdayOfFirst: Int {
        Calendar.current.component(.weekday, from: firstDayOfMonth)
    }

    /// 格式化输出
    func toString(_ format: String = "yyyy-MM") -> String {
        let df = DateFormatter()
        df.dateFormat = format
        return df.string(from: self)
    }

    /// 加减月
    func adding(months: Int) -> Date {
        Calendar.current.date(byAdding: .month, value: months, to: self)!
    }
    
    func isSameDate(_ date: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: date)
    }
}

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

    private let bgImgv = UIImageView()
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
        dateLabel.textColor = .eHex("#000000", alpha: 0.3)
        if hasData {
            dateLabel.textColor = .eHex("#000000", alpha: 0.9)
        }
        if isSelected {
            bgImgv.isHidden = false
            bgImgv.backgroundColor = .eHex("#ffffff")
        } else {
            bgImgv.isHidden = true
        }
        if isToday {
            bgImgv.isHidden = false
            bgImgv.backgroundColor = .eHex("#F0F0F0")
            dateLabel.textColor = .eHex("#000000", alpha: 0.9)
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError() }
}

// MARK: - CalendarPickerView

class CalendarPickerView: BasicView {
    // MARK: UI Components

    private let header: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()

    private let prevBtn = UIButton()
    private let nextBtn = UIButton()
    private let closeBtn = UIButton()
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
    private let selectedSubject = PublishSubject<Date>()
    public var selectedDate: Observable<Date> { selectedSubject.asObservable() }

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
                s.currentMonth = s.currentMonth.adding(months: 1)
                s.loadMonth(s.currentMonth)
            })
            .disposed(by: disposeBag)
        // 关闭
        closeBtn.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.removeFromSuperview()
            })
            .disposed(by: disposeBag)

        daysRelay
            .bind(to: collectionView.rx.items(
                cellIdentifier: CalendarDateCell.reuseId,
                cellType: CalendarDateCell.self
            )) { _, dateOpt, cell in
                if let date = dateOpt {
                    let day = Calendar.current.component(.day, from: date)
                    cell.dateLabel.text = "\(day)"
                    cell.isUserInteractionEnabled = true
                    cell.config(dayText: "\(day)", isSelected: false, hasData: true, isToday: date.isSameDate(Date()))
                } else {
                    cell.dateLabel.text = nil
                    cell.isUserInteractionEnabled = false
                }
            }
            .disposed(by: disposeBag)

        // 选中事件
        collectionView.rx.itemSelected
            .withLatestFrom(daysRelay) { $1[$0.item] }
            .compactMap { $0 }
            .bind(to: selectedSubject)
            .disposed(by: disposeBag)

        collectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)
    }

    private func loadMonth(_ month: Date) {
        titleLabel.text = month.toString("yyyy-MM")

        var arr: [Date?] = []
        // 前面空格
        for i in 1 ..< month.weekdayOfFirst {
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
    }

    override func initData() {
        super.initData()
        calendar.selectedDate
            .subscribe(onNext: { date in
                print("选中了：", date)
            })
            .disposed(by: disposeBag)
    }
}
