//
//  SyncRecordVC.swift
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2025/8/4.
//  Copyright © 2025 杰理科技. All rights reserved.
//

import Foundation

class SyncRecordVC: BasicViewController {
    let scrollView = UIScrollView()
    let syncShowView = SyncPlayBackView()
    let controlView = RecordPlayerView()
    var groupId = ""
    var viewModel = SyncRecordViewModel()
    let disposeBag = DisposeBag()

    override func initUI() {
        super.initUI()
        view.backgroundColor = .white
        view.addSubview(scrollView)
        view.addSubview(controlView)
        scrollView.addSubview(syncShowView)

        controlView.backgroundColor = .white

        scrollView.snp.makeConstraints { make in
            make.top.equalTo(naviView.snp.bottom)
            make.left.right.equalToSuperview()
            make.width.equalToSuperview()
            make.bottom.equalTo(controlView.snp.top)
        }

        syncShowView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }

        controlView.snp.makeConstraints { make in
            make.top.equalTo(scrollView.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(90 + controlView.bottomInset)
            make.bottom.equalToSuperview()
        }
    }

    override func initData() {
        super.initData()
        let dt = Date.strBeDate(groupId)
        naviView.titleLab.text = dt?.toString("yyyy-MM-dd HH:mm")

        viewModel.originText.subscribe(onNext: { [weak self] text in
            guard let self = self else { return }
            self.syncShowView.originalLab.text = text
            self.updatePlaybackSegmentsIfReady()
        }).disposed(by: disposeBag)

        viewModel.translateText.subscribe(onNext: { [weak self] text in
            guard let self = self else { return }
            self.syncShowView.translateLab.text = text
            self.updatePlaybackSegmentsIfReady()
        }).disposed(by: disposeBag)

        viewModel.showGroupText.subscribe(
            onNext: { [weak self] text in
                guard let self = self else { return }
                self.syncShowView.currentHightText(
                    text.0,
                    translateText: text.1
                )
            }).disposed(by: disposeBag)

        viewModel.allTime.subscribe(onNext: { [weak self] allTime in
            guard let self = self else { return }
            controlView.allTime(allTime)
        }).disposed(by: disposeBag)

        viewModel.currentDuration.subscribe(onNext: { [weak self] duration in
            guard let self = self else { return }
            self.controlView.slider.maximumValue = Float(duration)
            self.controlView.slider.minimumValue = 0
        }).disposed(by: disposeBag)

        viewModel.progress.subscribe(onNext: { [weak self] progress in
            self?.controlView.slider.value = progress
        }).disposed(by: disposeBag)

        viewModel.playStatus.subscribe(onNext: { [weak self] status in
            guard let self = self else { return }
            self.controlView.updateStatus(status)
        }).disposed(by: disposeBag)

        viewModel.currentTime.subscribe(onNext: { [weak self] currentTime in
            guard let self = self else { return }
            self.controlView.currentTime(currentTime)
        }).disposed(by: disposeBag)

        controlView.slider.rx.controlEvent(.touchUpInside).asObservable().subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            self.viewModel.seekTo(Double(controlView.slider.value))
        }).disposed(by: disposeBag)

        controlView.controlBtn.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            self.viewModel.ppCtrl()
        }).disposed(by: disposeBag)

        // 监听句子点击事件：根据索引获取起始时间并跳转播放
        syncShowView.onOriginalSentenceTap = { [weak self] index in
            guard let self = self else { return }
            let start = self.viewModel.sentenceStartTime(at: index)
            self.viewModel.seekTo(start)
        }
        syncShowView.onTranslateSentenceTap = { [weak self] index in
            guard let self = self else { return }
            let start = self.viewModel.sentenceStartTime(at: index)
            self.viewModel.seekTo(start)
        }

        viewModel.initData(groupId: groupId)
    }

    private func updatePlaybackSegmentsIfReady() {
        guard let oText = syncShowView.originalLab.text,
              let tText = syncShowView.translateLab.text else { return }
        let segs = viewModel.sentenceRanges(forOriginal: oText, translate: tText)
        syncShowView.configureSegments(originalSegments: segs.orig, translateSegments: segs.trans)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.stop()
    }
}
