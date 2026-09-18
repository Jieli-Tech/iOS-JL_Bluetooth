//
//  StreamPushViewController.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2026/5/28.
//  Copyright © 2026 www.zh-jieli.com. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import JLLogHelper

class StreamPushViewController: BaseViewController {

    private let scrollView = UIScrollView()
    private let stackView = UIStackView()

    private let previewImageView = UIImageView()
    private let previewContainer = UIView()
    private let statusView = PushStatusView()
    private let codecSelectionView = CodecSelectionView()
    private let fpsControlView = FPSControlView()
    private let controlPanelView = PushControlPanelView()

    private let viewModel = StreamPushViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationView.title = "视频推送"
        navigationView.leftBtn.setTitle("返回", for: .normal)
        setupUI()
        bindViewModel()
    }

    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(navigationView.snp.bottom).offset(10)
            make.left.right.bottom.equalToSuperview()
        }

        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        scrollView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
            make.width.equalToSuperview().offset(-32)
        }

        // Preview area
        previewContainer.backgroundColor = .black
        previewContainer.layer.cornerRadius = 8
        previewContainer.clipsToBounds = true
        previewImageView.contentMode = .scaleAspectFit
        previewContainer.addSubview(previewImageView)
        previewImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        stackView.addArrangedSubview(previewContainer)
        previewContainer.snp.makeConstraints { make in
            make.height.equalTo(240)
        }

        // Status display
        stackView.addArrangedSubview(statusView)
        statusView.snp.makeConstraints { make in
            make.height.equalTo(44)
        }

        // Codec selection
        stackView.addArrangedSubview(codecSelectionView)
        codecSelectionView.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(80)
        }

        // FPS control
        stackView.addArrangedSubview(fpsControlView)

        // Push controls
        stackView.addArrangedSubview(controlPanelView)
    }

    private func bindViewModel() {
        navigationView.leftBtn.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)

        let vm = viewModel

        // Inputs
        controlPanelView.startTap.bind(to: vm.startPushCommand).disposed(by: disposeBag)
        controlPanelView.pauseTap.bind(to: vm.pausePushCommand).disposed(by: disposeBag)
        controlPanelView.resumeTap.bind(to: vm.resumePushCommand).disposed(by: disposeBag)
        controlPanelView.stopTap.bind(to: vm.stopPushCommand).disposed(by: disposeBag)
        controlPanelView.resetTap.bind(to: vm.resetPushCommand).disposed(by: disposeBag)
        controlPanelView.closeTap.bind(to: vm.closePushCommand).disposed(by: disposeBag)
        controlPanelView.retryTap.bind(to: vm.retryPushCommand).disposed(by: disposeBag)
        fpsControlView.decreaseTap.bind(to: vm.decreaseFPSCommand).disposed(by: disposeBag)
        fpsControlView.increaseTap.bind(to: vm.increaseFPSCommand).disposed(by: disposeBag)

        codecSelectionView.jpegTap
            .map { StreamCodecType.jpeg }
            .bind(to: vm.selectCodecCommand)
            .disposed(by: disposeBag)
        codecSelectionView.h264Tap
            .map { StreamCodecType.h264 }
            .bind(to: vm.selectCodecCommand)
            .disposed(by: disposeBag)

        // Outputs
        statusView.bind(statusDriver: vm.pushStatus)

        codecSelectionView.bind(selectedCodec: vm.selectedCodec)
        codecSelectionView.bind(isSelectable: vm.isCodecSelectable)

        fpsControlView.bind(fpsDriver: vm.fps)
        fpsControlView.bind(decreaseEnabled: vm.isFPSDecreaseEnabled)
        fpsControlView.bind(increaseEnabled: vm.isFPSIncreaseEnabled)

        controlPanelView.bindButtonStates(
            startEnabled: vm.isStartButtonEnabled,
            pauseEnabled: vm.isPauseButtonEnabled,
            resumeEnabled: vm.isResumeButtonEnabled,
            stopEnabled: vm.isStopButtonEnabled,
            resetEnabled: vm.isResetButtonEnabled,
            closeEnabled: vm.isCloseButtonEnabled,
            retryVisible: vm.isRetryButtonVisible
        )

        vm.previewImage
            .drive(previewImageView.rx.image)
            .disposed(by: disposeBag)

        vm.alertMessage
            .drive(onNext: { [weak self] message in
                self?.showAlert(message: message)
            })
            .disposed(by: disposeBag)
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "提示", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
}
