import UIKit

protocol HorizontalMultiPickerViewDelegate: AnyObject {
    func multiPickerView(_ pickerView: PickerView, didConfirmSelection selections: [Int])
    func multiPickerView(_ pickerView: PickerView, didChangeSelection selections: [Int])
}

class PickerView: UIView {

    // 配置选项
    public struct Configuration {
        var showsMagnifier: Bool = true
        var showsScrollIndicator: Bool = true
        var autoAdjustFontSize: Bool = true
        var baseFontSize: CGFloat = 16
        var baseRowHeight: CGFloat = 80
    }

    // 公开属性
    public var dataSources: [[String]] = [] {
        didSet { reloadData() }
    }
    public var columnTitles: [String]? {
        didSet { updateColumnTitles() }
    }
    public private(set) var selectedIndexes: [Int] = []
    public var confirmButtonConfig: (title: String, color: UIColor) = (R.localStr.oK(), .systemBlue) {
        didSet { updateConfirmButton() }
    }
    public var showsSelectionLabel: Bool = true {
        didSet { selectionLabel.isHidden = !showsSelectionLabel }
    }
    public var configuration = Configuration()
    public weak var delegate: HorizontalMultiPickerViewDelegate?

    // 私有属性
    private lazy var pickerView: UIPickerView = {
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        picker.transform = CGAffineTransform(rotationAngle: -90 * (.pi / 180))
        return picker
    }()

    private lazy var confirmButton = UIButton(type: .system)
    private lazy var selectionLabel = UILabel()
    private lazy var titleStackView = UIStackView()
    private var magnifierView: UILabel?
    private var scrollIndicator: UIView?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    // MARK: - UI Setup
    private func setupUI() {
        backgroundColor = .systemBackground
        setupPickerView()
        setupConfirmButton()
        setupSelectionLabel()
        setupTitleStackView()
         // Add subviews
        addSubview(titleStackView)
        addSubview(pickerView)
        addSubview(selectionLabel)
        addSubview(confirmButton)
        setupConstraints()

        if configuration.showsMagnifier {
            setupMagnifier()
        }

        if configuration.showsScrollIndicator {
            setupScrollIndicator()
        }

    }

    private func setupPickerView() {
        pickerView.delegate = self
        pickerView.dataSource = self
    }

    private func setupConfirmButton() {
        
        confirmButton.setTitle(R.localStr.oK(), for: .normal)
        confirmButton.setTitleColor(.white, for: .normal)
        confirmButton.backgroundColor = .systemBlue
        confirmButton.layer.cornerRadius = 8
        confirmButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
    }

    private func setupSelectionLabel() {
        selectionLabel.textAlignment = .center
        selectionLabel.font = UIFont.systemFont(ofSize: 16)
        selectionLabel.numberOfLines = 0
        selectionLabel.adjustsFontSizeToFitWidth = true
    }

    private func setupTitleStackView() {
        titleStackView.axis = .horizontal
        titleStackView.distribution = .fillEqually
        titleStackView.alignment = .center
    }

    private func setupMagnifier() {
        let magnifier = UILabel()
        magnifier.backgroundColor = UIColor.systemBackground
        magnifier.textAlignment = .center
        magnifier.font = UIFont.boldSystemFont(ofSize: 18)
        magnifier.layer.cornerRadius = 8
        magnifier.layer.masksToBounds = true
        magnifier.layer.borderWidth = 1
        magnifier.layer.borderColor = UIColor.systemGray.cgColor
        magnifier.alpha = 0
        addSubview(magnifier)
        magnifierView = magnifier

        magnifier.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(pickerView.snp.top).offset(-10)
            make.width.equalToSuperview().multipliedBy(0.7)
            make.height.equalTo(50)
        }
    }

    private func setupScrollIndicator() {
        let indicator = UIView()
        indicator.backgroundColor = UIColor.systemGray.withAlphaComponent(0.5)
        indicator.layer.cornerRadius = 2
        pickerView.addSubview(indicator)
        scrollIndicator = indicator

        indicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            indicator.leadingAnchor.constraint(equalTo: pickerView.leadingAnchor),
            indicator.trailingAnchor.constraint(equalTo: pickerView.trailingAnchor),
            indicator.bottomAnchor.constraint(equalTo: pickerView.bottomAnchor, constant: -5),
            indicator.heightAnchor.constraint(equalToConstant: 3)
        ])
    }

    // MARK: - Constraints
    private func setupConstraints() {
        titleStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(10)
            make.height.equalTo(30)
        }

        pickerView.snp.makeConstraints { make in
            make.top.equalTo(titleStackView.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.width.equalTo(300)  // 实际显示的高度
            make.height.equalTo(300) // 控制横向滚动范围
        }

        selectionLabel.snp.makeConstraints { make in
            make.top.equalTo(pickerView.snp.bottom).offset(15)
            make.left.right.equalToSuperview().inset(20)
        }

        confirmButton.snp.makeConstraints { make in
            make.top.equalTo(selectionLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.height.equalTo(44)
            make.width.equalToSuperview().inset(20)
        }
    }

    // MARK: - Public Methods
    public func reloadData() {
        selectedIndexes = Array(repeating: 0, count: dataSources.count)
        pickerView.reloadAllComponents()
        updateSelectionLabel()
    }

    public func setSelectedIndexes(_ indexes: [Int], animated: Bool = false) {
        guard indexes.count == dataSources.count else { return }
        selectedIndexes = indexes
        for (component, index) in indexes.enumerated() {
            pickerView.selectRow(index, inComponent: component, animated: animated)
        }
        updateSelectionLabel()
    }

    public func getSelectedTexts() -> [String] {
        return selectedIndexes.enumerated().map { (component, index) in
            guard component < dataSources.count, index < dataSources[component].count else { return "" }
            return dataSources[component][index]
        }
    }

    public func updateData(_ data: [String], forComponent component: Int) {
        guard component < dataSources.count else { return }
        dataSources[component] = data
        pickerView.reloadComponent(component)
        updateSelectionLabel()
    }

    // MARK: - Private Methods
    private func updateColumnTitles() {
        titleStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        guard let titles = columnTitles, !titles.isEmpty else { return }

        for title in titles {
            let label = UILabel()
            label.text = title
            label.textAlignment = .center
            label.font = UIFont.boldSystemFont(ofSize: 14)
            titleStackView.addArrangedSubview(label)
        }
    }

    private func updateConfirmButton() {
        confirmButton.setTitle(confirmButtonConfig.title, for: .normal)
        confirmButton.backgroundColor = confirmButtonConfig.color
    }

    private func updateSelectionLabel() {
        let texts = getSelectedTexts()
        selectionLabel.text = texts.reversed().joined(separator: " - ")
        delegate?.multiPickerView(self, didChangeSelection: selectedIndexes)
    }

    @objc private func confirmButtonTapped() {
        delegate?.multiPickerView(self, didConfirmSelection: selectedIndexes)
    }
}

// MARK: - UIPickerView DataSource & Delegate
extension PickerView: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return dataSources.count
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        guard component < dataSources.count else { return 0 }
        return dataSources[component].count
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0

        guard component < dataSources.count, row < dataSources[component].count else {
            label.text = ""
            return label
        }

        let text = dataSources[component][row]
        label.text = text

        if configuration.autoAdjustFontSize {
            label.adjustsFontSizeToFitWidth = true
            label.minimumScaleFactor = 0.5

            let length = text.count
            let fontSize: CGFloat

            switch length {
            case 0..<5: fontSize = configuration.baseFontSize
            case 5..<10: fontSize = configuration.baseFontSize - 2
            case 10..<15: fontSize = configuration.baseFontSize - 4
            default: fontSize = configuration.baseFontSize - 6
            }

            label.font = UIFont.systemFont(ofSize: fontSize)
        } else {
            label.font = UIFont.systemFont(ofSize: configuration.baseFontSize)
        }

        label.transform = CGAffineTransform(rotationAngle: 90 * (.pi / 180))
        return label
    }

    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        guard configuration.autoAdjustFontSize, component < dataSources.count,
              let longestText = dataSources[component].max(by: { $1.count > $0.count }) else {
            return configuration.baseRowHeight
        }

        switch longestText.count {
        case 0..<10: return configuration.baseRowHeight
        case 10..<15: return configuration.baseRowHeight + 20
        case 15..<20: return configuration.baseRowHeight + 40
        default: return configuration.baseRowHeight + 60
        }
    }

    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        let totalWidth = bounds.width - 40
        let columnCount = CGFloat(max(1, dataSources.count))
        return totalWidth / columnCount - 10
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard component < selectedIndexes.count else { return }
        selectedIndexes[component] = row
        updateSelectionLabel()

        // 显示放大镜效果
        if configuration.showsMagnifier, let magnifier = magnifierView {
            magnifier.text = dataSources[component][row]

            UIView.animate(withDuration: 0.3, animations: {
                magnifier.alpha = 1
                magnifier.transform = .identity
            }) { _ in
                UIView.animate(withDuration: 0.3, delay: 1, options: [], animations: {
                    magnifier.alpha = 0
                    magnifier.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                }, completion: nil)
            }
        }
    }
}

// MARK: - UIScrollView Delegate
extension PickerView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard configuration.showsScrollIndicator, let indicator = scrollIndicator else { return }

        let offsetX = scrollView.contentOffset.x
        let contentWidth = scrollView.contentSize.width
        let scrollWidth = scrollView.bounds.width

        if contentWidth > scrollWidth {
            let progress = offsetX / (contentWidth - scrollWidth)
            let indicatorWidth = pickerView.bounds.width * 0.3
            let maxOffset = pickerView.bounds.width - indicatorWidth
            indicator.frame.origin.x = progress * maxOffset
            indicator.frame.size.width = indicatorWidth
        }
    }
}
