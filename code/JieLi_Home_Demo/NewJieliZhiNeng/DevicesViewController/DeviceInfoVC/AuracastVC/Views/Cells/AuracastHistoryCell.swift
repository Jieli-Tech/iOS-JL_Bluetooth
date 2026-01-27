//
//  AuracastHistoryCell.swift
//  JieLiAuracastAssistant
//
//  Created by EzioChan on 2024/9/30.
//

import UIKit



enum BroadcastStrongType: Int {
    case watching = 2
    case near = 1
    case history = 0
}

class AuracastHistoryCell: UITableViewCell {
    private let imgv = UIImageView()
    private let nameLab = UILabel()
    private let selectView = SelectLanguageView()
    private let moreImgv = UIImageView()
    private let loadingView = UIActivityIndicatorView()
    private let disposeBag: DisposeBag = .init()
    private let gifPath = Bundle.main.url(forResource: "receiving", withExtension: "gif")
    private var currentModel: BroadcastDBInfo!
    var callback: ((_ model: BroadcastDBInfo) -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(imgv)
        contentView.addSubview(nameLab)
        contentView.addSubview(selectView)
        contentView.addSubview(moreImgv)
        contentView.addSubview(loadingView)

        backgroundColor = .clear
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true

        imgv.image = R.image.icon_broadcast_on()
        nameLab.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        nameLab.textColor = R.color.fontBackText242424()

        moreImgv.image = R.image.icon_next_black()
        loadingView.hidesWhenStopped = true
        loadingView.isHidden = true
        loadingView.color = R.color.fontBackText_50()

        selectView.isHidden = true
        selectView.handle.subscribe { [weak self] _ in
            guard let self = self else { return }
            self.callback?(self.currentModel)
        }.disposed(by: disposeBag)

        imgv.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(32)
        }

        nameLab.snp.makeConstraints { make in
            make.left.equalTo(imgv.snp.right).offset(8)
            make.centerY.equalToSuperview()
        }

        selectView.snp.makeConstraints { make in
            make.left.equalTo(nameLab.snp.right).offset(8)
            make.centerY.equalToSuperview()
            make.height.equalTo(24)
        }

        moreImgv.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }

        loadingView.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        /// 查找承载侧滑的父视图
        if let superView = superview,
           NSStringFromClass(superView.classForCoder) == "_UITableViewCellSwipeContainerView" {
            /// 修改Cell圆角样式
            let maskPath = UIBezierPath(roundedRect: superView.bounds, cornerRadius: 8)
            let maskLayer = CAShapeLayer()
            maskLayer.frame = superView.bounds
            maskLayer.path = maskPath.cgPath
            superView.layer.mask = maskLayer
            /// 查找侧滑删除摁钮视图
            if let subView = superView.subviews.first,
               NSStringFromClass(subView.classForCoder) == "UISwipeActionPullView" {
                /// 修改侧滑视图背景色和摁钮背景色
                subView.backgroundColor = .clear
                let btn = subView.subviews.last
                if imgv.image == R.image.icon_broadcast_on() {
                    btn?.backgroundColor = R.color.fontGrayText838383()
                } else {
                    btn?.backgroundColor = .red
                }
            }
        }
    }

    override var frame: CGRect {
        didSet {
            var newFrame = frame
            newFrame.size.height -= 8
            newFrame.origin.y += 4
            newFrame.origin.x += 12
            newFrame.size.width -= 24
            super.frame = newFrame
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func cellConfig(bassModel: BroadcastDBInfo, _ isOn: Bool, _ isLosding: Bool = false, _ isNear: Bool = false) {
        currentModel = bassModel
        nameLab.text = bassModel.model.broadcastName
//        selectView.isHidden = !isOn
        selectView.setLanguage(languageForISO6393Code(code: "zho") ?? "")
        selectView.isHidden = true

        if isLosding {
            loadingView.isHidden = false
            loadingView.startAnimating()
            moreImgv.isHidden = true
            imgv.stopAnimating()
            imgv.animationImages = nil
            imgv.image = R.image.icon_broadcast_on_near()
        } else {
            loadingView.isHidden = true
//            moreImgv.isHidden = !isOn
            moreImgv.isHidden = true
            loadingView.stopAnimating()
            if isOn {
                setUpGifAnimation()
            } else {
                imgv.animationImages = nil
                imgv.stopAnimating()
                imgv.image = isNear ? R.image.icon_broadcast_on_near() : R.image.icon_broadcast_on()
            }
        }
        layoutSubviews()
    }

    private func setUpGifAnimation() {
        var images: [UIImage] = []
        images.append(RResources.image.icon_broadcast_on_01()!)
        images.append(RResources.image.icon_broadcast_on_02()!)
        images.append(RResources.image.icon_broadcast_on_03()!)
        images.append(RResources.image.icon_broadcast_on_04()!)
        images.append(RResources.image.icon_broadcast_on_05()!)
        imgv.contentMode = .scaleAspectFit
        imgv.animationImages = images
        imgv.animationDuration = 1.0
        imgv.animationRepeatCount = 0
        imgv.startAnimating()
    }
    
    private func languageForISO6393Code(code: String) -> String? {
        let languages: [String: String] = [
            "eng": R.localStr.english_2(),
            "zho": R.localStr.chinese(),
            "jpn": R.localStr.japanese_2(),
            "kor": R.localStr.korean(),
            "rus": R.localStr.russian(),
            "ita": R.localStr.italian(),
            "fra": R.localStr.french(),
            "deu": R.localStr.german(),
            "tha": R.localStr.thai(),
            "vie": R.localStr.vietnamese(),
            "spa": R.localStr.spanish(),
            "por": R.localStr.portuguese(),
            "ara": R.localStr.arabic(),
            "nld": R.localStr.dutch(),
            "ind": R.localStr.indonesian(),
            "msa": R.localStr.malay(),
            "swe": R.localStr.swedish(),
            "fin": R.localStr.finnish(),
            "tur": R.localStr.turkish(),
            "ell": R.localStr.greek(),
            "pol": R.localStr.polish(),
            "ces": R.localStr.czech(),
            "hun": R.localStr.hungarian(),
            "nor": R.localStr.norwegian(),
            "dan": R.localStr.danish(),
            "isl": R.localStr.icelandic(),
            "sqi": R.localStr.albanian(),
            "swa": R.localStr.swahili(),
            "heb": R.localStr.hebrew(),
            "urd": R.localStr.urdu()
        ]
        return languages[code]
    }
}

private class SelectLanguageView: BasicView {
    private let languageLab = UILabel()
    private let languageImgv = UIImageView()
    private let btn = UIButton()
    var handle = PublishSubject<Void>()

    override func initUI() {
        super.initUI()
        addSubview(btn)
        btn.addSubview(languageLab)
        btn.addSubview(languageImgv)
        backgroundColor = .eHex("#E4F2FF")
        layer.cornerRadius = 3
        layer.masksToBounds = true
        layer.borderWidth = 1
        layer.borderColor = UIColor.eHex("#0082FC").cgColor

        languageLab.text = R.localStr.chinese()
        languageLab.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        languageLab.textColor = .eHex("#007AEE")

        languageImgv.image = R.image.icon_down_blue()
        languageImgv.contentMode = .scaleAspectFit

        btn.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        languageLab.snp.makeConstraints { make in
            make.top.left.bottom.equalToSuperview().inset(4)
            make.right.equalTo(languageImgv.snp.left).inset(-2)
        }

        languageImgv.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.width.equalTo(10)
            make.right.equalToSuperview().inset(4)
        }
        btn.rx.tap.asObservable().bind(to: handle).disposed(by: disposeBag)
    }

    func setEnabled(_ enabled: Bool) {
        btn.isEnabled = enabled
        if enabled {
            backgroundColor = .eHex("#E4F2FF")
            layer.borderColor = UIColor.eHex("#0082FC").cgColor
            languageLab.textColor = .eHex("#007AEE")
        } else {
            backgroundColor = .eHex("#E4E4E4")
            layer.borderColor = UIColor.eHex("#E0E0E0").cgColor
            languageLab.textColor = .eHex("#B9B9B9")
        }
    }

    func setLanguage(_ language: String) {
        if language.count == 0 {
            isHidden = true
        } else {
            isHidden = false
        }
        languageLab.text = language
    }
}
