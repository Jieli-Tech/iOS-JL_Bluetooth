//
//  FaceToFaceRecordVC.swift
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2025/9/9.
//  Copyright © 2025 杰理科技. All rights reserved.
//

import Foundation

class FaceToFaceRecordVC: BasicViewController {
    var dataVM: FaceToFaceRecordViewModel?
    private let chatView = ChatDialogView()
    private let bottomPlayView = RecordPlayerView()
    private let disposeBag = DisposeBag()
    private var seekDisposable: Disposable?

    override func initUI() {
        super.initUI()
        view.backgroundColor = .white
        naviView.titleLab.text = dataVM?.groupId.value.toString("yyyy-MM-dd HH:mm")
        view.addSubview(chatView)
        view.addSubview(bottomPlayView)

        chatView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(naviView.snp.bottom).offset(10)
            make.bottom.equalTo(bottomPlayView.snp.top)
        }

        bottomPlayView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(80 + bottomPlayView.bottomInset)
            make.bottom.equalToSuperview()
        }
    }

    override func initData() {
        super.initData()
        dataVM?.messageList.subscribe(onNext: { [weak self] messageList in
            guard let self = self else { return }
            chatView.messages.accept(messageList)
        }).disposed(by: disposeBag)

        bottomPlayView.controlBtn.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            if dataVM?.playStatus.value == true {
                dataVM?.pause()
            } else {
                dataVM?.play()
            }
        }).disposed(by: disposeBag)

        bottomPlayView.slider.rx.controlEvent(.touchUpInside).asObservable().subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            dataVM?.seekTo(Double(bottomPlayView.slider.value))
            makeSeekDisposable()
        }).disposed(by: disposeBag)

        bottomPlayView.slider.rx.controlEvent(.touchDown).asObservable().subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            self.seekDisposable?.dispose()
        }).disposed(by: disposeBag)

        bottomPlayView.slider.rx.controlEvent(.touchCancel).asObservable().subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            makeSeekDisposable()
        }).disposed(by: disposeBag)

        dataVM?.playStatus.subscribe(onNext: { [weak self] status in
            guard let self = self else { return }
            self.bottomPlayView.updateStatus(status)
        }).disposed(by: disposeBag)

        dataVM?.currentTime.subscribe(onNext: { [weak self] currentTime in
            guard let self = self else { return }
            bottomPlayView.currentTime(currentTime)
        }).disposed(by: disposeBag)

        dataVM?.allDuration.subscribe(onNext: { [weak self] duration in
            guard let self = self else { return }
            bottomPlayView.slider.maximumValue = Float(duration)
            bottomPlayView.slider.minimumValue = 0
        }).disposed(by: disposeBag)

        dataVM?.allTime.subscribe(onNext: { [weak self] allTime in
            guard let self = self else { return }
            bottomPlayView.allTime(allTime)
        }).disposed(by: disposeBag)

        seekDisposable = dataVM?.progress.subscribe(onNext: { [weak self] progress in
            guard let self = self else { return }
            bottomPlayView.slider.value = progress
        })

        chatView.tableBag?.dispose()

        dataVM?.currentPlayIndex.distinctUntilChanged().observe(on: MainScheduler.instance).subscribe(onNext: {
            [weak self] index in
            self?.chatView.scrollToIndex(index)
        }).disposed(by: disposeBag)
        
        chatView.didSelect = { [weak self] model in
            guard let self = self else { return }
            dataVM?.seekTo(model.startTime)
        }
        
    }

    private func makeSeekDisposable() {
        seekDisposable?.dispose()
        seekDisposable = dataVM?.progress.subscribe(onNext: { [weak self] progress in
            guard let self = self else { return }
            bottomPlayView.slider.value = progress
        })
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        dataVM?.stop()
        seekDisposable?.dispose()
    }
}
