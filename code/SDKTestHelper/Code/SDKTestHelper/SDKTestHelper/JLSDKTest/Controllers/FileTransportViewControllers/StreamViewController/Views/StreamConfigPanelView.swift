//
//  StreamConfigPanelView.swift
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

struct OptionItem {
    let name: String
    let value: UInt8
}

class PeripheralConfigItemView: UIView {
    let responseModel: JLStreamPeripheralResponseModel
    
    private let toggleSwitch = UISwitch()
    private let titleLabel = UILabel()
    private let codecButton = UIButton(type: .system)
    private let srButton = UIButton(type: .system)
    private let infoLabel = UILabel()
    
    private let disposeBag = DisposeBag()
    
    private let selectedCodec = BehaviorRelay<UInt8>(value: 0)
    private let selectedSR = BehaviorRelay<UInt8>(value: 0)
    
    private var codecOptions: [OptionItem] = []
    private var srOptions: [OptionItem] = []
    
    var requestModel: RxSwift.Observable<JLStreamPeripheralRequestModel?> {
        return RxSwift.Observable.combineLatest(
            toggleSwitch.rx.isOn.asObservable(),
            selectedCodec.asObservable(),
            selectedSR.asObservable()
        ).map { [weak self] isOn, codec, sr in
            guard let self = self, isOn else { return nil }
            let req = JLStreamPeripheralRequestModel(
                type: self.responseModel.type,
                index: 0, // will be assigned later
                number: self.responseModel.number,
                codec: codec
            )
            if self.responseModel.type == .mic {
                req.sr = sr
            } else if self.responseModel.type == .camera {
                req.fps = self.responseModel.fps
                req.width = self.responseModel.width
                req.height = self.responseModel.height
            }
            return req
        }
    }
    
    init(model: JLStreamPeripheralResponseModel) {
        self.responseModel = model
        super.init(frame: .zero)
        setupUI()
        bindUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        self.backgroundColor = UIColor.compatibleSecondarySystemBackground
        self.layer.cornerRadius = 8
        
        let typeName = responseModel.type == .camera ? "Camera" : "Mic"
        titleLabel.text = "\(typeName) (Num: \(responseModel.number))"
        titleLabel.font = .boldSystemFont(ofSize: 14)
        titleLabel.textColor = .darkText
        
        let headerStack = UIStackView(arrangedSubviews: [titleLabel, toggleSwitch])
        headerStack.axis = .horizontal
        headerStack.alignment = .center
        
        let paramsStack = UIStackView()
        paramsStack.axis = .vertical
        paramsStack.spacing = 8
        
        if responseModel.type == .mic {
            codecOptions = getMicCodecOptions(mask: responseModel.codec)
            srOptions = getMicSROptions(mask: responseModel.sr)
            
            selectedCodec.accept(codecOptions.first?.value ?? 0)
            selectedSR.accept(srOptions.first?.value ?? 0)
            
            codecButton.setTitle("Codec: \(codecOptions.first?.name ?? "N/A")", for: .normal)
            codecButton.setTitleColor(.darkText, for: .normal)
            srButton.setTitle("SR: \(srOptions.first?.name ?? "N/A")", for: .normal)
            srButton.setTitleColor(.darkText, for: .normal)
            
            codecButton.contentHorizontalAlignment = .left
            srButton.contentHorizontalAlignment = .left
            
            paramsStack.addArrangedSubview(codecButton)
            paramsStack.addArrangedSubview(srButton)
            
        } else if responseModel.type == .camera {
            codecOptions = getCameraCodecOptions(mask: responseModel.codec)
            selectedCodec.accept(codecOptions.first?.value ?? 0)
            
            codecButton.setTitle("Codec: \(codecOptions.first?.name ?? "N/A")", for: .normal)
            codecButton.setTitleColor(.darkText, for: .normal)
            codecButton.contentHorizontalAlignment = .left
            
            infoLabel.text = "Res: \(responseModel.width)x\(responseModel.height) @\(responseModel.fps)fps"
            infoLabel.font = .systemFont(ofSize: 12)
            infoLabel.textColor = UIColor.compatibleSecondaryLabel
            
            paramsStack.addArrangedSubview(codecButton)
            paramsStack.addArrangedSubview(infoLabel)
        }
        
        let mainStack = UIStackView(arrangedSubviews: [headerStack, paramsStack])
        mainStack.axis = .vertical
        mainStack.spacing = 8
        self.addSubview(mainStack)
        mainStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
        }
        
        // Disable params if switch is off
        toggleSwitch.rx.isOn.bind { isOn in
            paramsStack.alpha = isOn ? 1.0 : 0.5
            paramsStack.isUserInteractionEnabled = isOn
        }.disposed(by: disposeBag)
        
        toggleSwitch.isOn = false
    }
    
    private func bindUI() {
        codecButton.rx.tap.bind { [weak self] in
            self?.showOptions(title: "Select Codec", options: self?.codecOptions ?? []) { selected in
                self?.selectedCodec.accept(selected.value)
                self?.codecButton.setTitle("Codec: \(selected.name)", for: .normal)
            }
        }.disposed(by: disposeBag)
        
        srButton.rx.tap.bind { [weak self] in
            self?.showOptions(title: "Select Sample Rate", options: self?.srOptions ?? []) { selected in
                self?.selectedSR.accept(selected.value)
                self?.srButton.setTitle("SR: \(selected.name)", for: .normal)
            }
        }.disposed(by: disposeBag)
    }
    
    private func showOptions(title: String, options: [OptionItem], onSelect: @escaping (OptionItem) -> Void) {
        guard let vc = self.findViewController() else { return }
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        for opt in options {
            alert.addAction(UIAlertAction(title: opt.name, style: .default, handler: { _ in
                onSelect(opt)
            }))
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        vc.present(alert, animated: true, completion: nil)
    }
    
    private func getMicCodecOptions(mask: UInt32) -> [OptionItem] {
        var options = [OptionItem]()
        // bit0: PCM, bit1: speex, bit2: opus, bit3: msbc, bit4: jla_v2
        if mask & (1 << 0) != 0 { options.append(OptionItem(name: "PCM", value: 0)) }
        if mask & (1 << 1) != 0 { options.append(OptionItem(name: "SPEEX", value: 1)) }
        if mask & (1 << 2) != 0 { options.append(OptionItem(name: "OPUS", value: 2)) }
        if mask & (1 << 3) != 0 { options.append(OptionItem(name: "MSBC", value: 3)) }
        if mask & (1 << 4) != 0 { options.append(OptionItem(name: "JLA_V2", value: 4)) }
        if options.isEmpty { options.append(OptionItem(name: "Default(0)", value: 0)) }
        return options
    }
    
    private func getCameraCodecOptions(mask: UInt32) -> [OptionItem] {
        var options = [OptionItem]()
        if mask & (1 << 0) != 0 { options.append(OptionItem(name: "JPEG", value: 0)) }
        if mask & (1 << 1) != 0 { options.append(OptionItem(name: "H.264", value: 1)) }
        if options.isEmpty { options.append(OptionItem(name: "JPEG", value: 0)) }
        return options
    }
    
    private func getMicSROptions(mask: UInt32) -> [OptionItem] {
        var options = [OptionItem]()
        let rates = [8000, 11025, 12000, 16000, 22050, 24000, 32000, 44100, 48000]
        for (i, rate) in rates.enumerated() {
            if mask & (1 << i) != 0 {
                options.append(OptionItem(name: "\(rate)Hz", value: UInt8(i)))
            }
        }
        if options.isEmpty { options.append(OptionItem(name: "16000Hz", value: 3)) }
        return options
    }
}

/// 流配置下发与开启面板
class StreamConfigPanelView: UIView {
    
    let startButton = UIButton(type: .system)
    let mtuTextField = UITextField()
    
    private let contentStackView = UIStackView()
    private let peripheralsStackView = UIStackView()
    private let itemViewsRelay = BehaviorRelay<[PeripheralConfigItemView]>(value: [])
    
    private let disposeBag = DisposeBag()
    
    // 向外暴露当前选中的配置 (JLStreamPeripheralRequestModel数组, MTU)
    var currentConfig: RxSwift.Observable<([JLStreamPeripheralRequestModel], UInt16)?> {
        let itemsObservable = itemViewsRelay.flatMapLatest { views -> RxSwift.Observable<[JLStreamPeripheralRequestModel]> in
            if views.isEmpty { return .just([]) }
            let observables = views.map { $0.requestModel }
            return RxSwift.Observable.combineLatest(observables).map { models in
                let validModels = models.compactMap { $0 }
                for (i, model) in validModels.enumerated() {
                    model.index = UInt8(i + 1)
                }
                return validModels
            }
        }
        
        return RxSwift.Observable.combineLatest(itemsObservable, mtuTextField.rx.text.asObservable())
            .map { (models, mtuStr) in
                if models.isEmpty { return nil }
                let mtu = UInt16(mtuStr ?? "512") ?? 512
                return (models, mtu)
            }
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
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
        
        // 使用 StackView 作为主布局容器，而不是 ScrollView
        contentStackView.axis = .vertical
        contentStackView.spacing = 16
        contentStackView.alignment = .fill
        self.addSubview(contentStackView)
        contentStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
        
        let titleLabel = UILabel()
        titleLabel.text = "配置与开启传输"
        titleLabel.font = .boldSystemFont(ofSize: 16)
        contentStackView.addArrangedSubview(titleLabel)
        
        let mtuLabel = UILabel()
        mtuLabel.text = "期望 MTU (最大传输单元)"
        mtuLabel.font = .systemFont(ofSize: 14)
        mtuLabel.textColor = UIColor.compatibleSecondaryLabel
        contentStackView.addArrangedSubview(mtuLabel)
        
        mtuTextField.placeholder = "默认 512"
        mtuTextField.keyboardType = .numberPad
        mtuTextField.borderStyle = .roundedRect
        mtuTextField.text = "512"
        mtuTextField.snp.makeConstraints { make in
            make.height.equalTo(44)
        }
        contentStackView.addArrangedSubview(mtuTextField)
        
        let periLabel = UILabel()
        periLabel.text = "可选外设 (打开开关并配置参数)"
        periLabel.font = .systemFont(ofSize: 14)
        periLabel.textColor = UIColor.compatibleSecondaryLabel
        contentStackView.addArrangedSubview(periLabel)
        
        peripheralsStackView.axis = .vertical
        peripheralsStackView.spacing = 12
        contentStackView.addArrangedSubview(peripheralsStackView)
        
        startButton.setTitle("发起传输请求", for: .normal)
        startButton.backgroundColor = UIColor.compatibleSystemBlue
        startButton.setTitleColor(UIColor.compatibleLabel, for: .normal)
        startButton.layer.cornerRadius = 8
        startButton.snp.makeConstraints { make in
            make.height.equalTo(44)
        }
        contentStackView.addArrangedSubview(startButton)
        
        // 当没有外设被选中时，禁用开启按钮
        currentConfig.map { $0 != nil && !$0!.0.isEmpty }
            .bind(to: startButton.rx.isEnabled)
            .disposed(by: disposeBag)
            
        currentConfig.map { $0 != nil && !$0!.0.isEmpty ? 1.0 : 0.5 }
            .bind(to: startButton.rx.alpha)
            .disposed(by: disposeBag)
            
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        self.addGestureRecognizer(tap)
    }
    
    @objc private func dismissKeyboard() {
        self.endEditing(true)
    }
    
    func bind(peripheralsDriver: Driver<[JLStreamPeripheralResponseModel]>) {
        peripheralsDriver
            .drive(onNext: { [weak self] models in
                guard let self = self else { return }
                
                // Clear old views
                self.peripheralsStackView.arrangedSubviews.forEach {
                    $0.removeFromSuperview()
                }
                
                var newViews = [PeripheralConfigItemView]()
                for model in models {
                    let itemView = PeripheralConfigItemView(model: model)
                    self.peripheralsStackView.addArrangedSubview(itemView)
                    newViews.append(itemView)
                }
                
                if models.isEmpty {
                    let emptyLabel = UILabel()
                    emptyLabel.text = "暂无可用外设"
                    emptyLabel.textColor = UIColor.compatibleSecondaryLabel
                    emptyLabel.textAlignment = .center
                    self.peripheralsStackView.addArrangedSubview(emptyLabel)
                }
                
                self.itemViewsRelay.accept(newViews)
            })
            .disposed(by: disposeBag)
    }
}

// Helper extension to find parent view controller
extension UIView {
    func findViewController() -> UIViewController? {
        if let nextResponder = self.next as? UIViewController {
            return nextResponder
        } else if let nextResponder = self.next as? UIView {
            return nextResponder.findViewController()
        } else {
            return nil
        }
    }
}
