//
//  CallRecordVC.swift
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2025/8/26.
//  Copyright © 2025 杰理科技. All rights reserved.
//

import UIKit

class CallRecordVC: BasicViewController {
    var callVM: CallRecordViewModel?
    private let chatView = ChatDialogView()
    private let bottomView = CallRecordBottomView()
    private let bottomPlayView = RecordPlayerView()
    private let disposeBag = DisposeBag()
    private var seekDisposable: Disposable?

    override func initUI() {
        super.initUI()
        view.backgroundColor = .white
        naviView.titleLab.text = callVM?.groupId.value.toString("yyyy-MM-dd HH:mm")
        view.addSubview(chatView)
        view.addSubview(bottomView)
        view.addSubview(bottomPlayView)

        bottomPlayView.isHidden = true

        chatView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(naviView.snp.bottom).offset(10)
            make.bottom.equalTo(bottomPlayView.snp.top)
        }

        bottomView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(80 + bottomView.bottomInset)
            make.bottom.equalToSuperview()
        }

        bottomPlayView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(90 + bottomPlayView.bottomInset)
            make.bottom.equalToSuperview()
        }
        bottomPlayView.controlBtn.snp.updateConstraints { make in
            make.width.equalTo(170)
        }
    }

    override func initData() {
        super.initData()
        callVM?.messageList.subscribe(onNext: { [weak self] messageList in
            guard let self = self else { return }
            chatView.messages.accept(messageList)
        }).disposed(by: disposeBag)
        bottomView.playOriginBtn.rx.tap.subscribe(
            onNext: { [weak self] _ in
                guard let self = self else { return }
                self.bottomPlayView.isHidden = false
                self.bottomView.isHidden = true
                bottomPlayView.config(
                    color: .eHex("#F89514"),
                    pointImg: "icon_slider_thint_yellow",
                    pauseText: "Playing original",
                    pauseImg: "icon_pause_yellow",
                    playText: "Play original",
                    playImg: "icon_pause_yellow"
                )
                callVM?.play(.original)
            }).disposed(by: disposeBag)

        bottomView.playTranslateBtn.rx.tap.subscribe(
            onNext: { [weak self] _ in
                guard let self = self else { return }
                self.bottomPlayView.isHidden = false
                self.bottomView.isHidden = true
                bottomPlayView.config(
                    color: .eHex("#448EFF"),
                    pointImg: "icon_slider_thint_blue",
                    pauseText: "Playing translated",
                    pauseImg: "icon_pause_blue",
                    playText: "Play translated",
                    playImg: "icon_pause_blue"
                )
                callVM?.play(.translate)
            }).disposed(by: disposeBag)

        bottomPlayView.controlBtn.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            self.bottomPlayView.isHidden = true
            self.bottomView.isHidden = false
            callVM?.stop()
        }).disposed(by: disposeBag)

        callVM?.playStatus.subscribe(onNext: { [weak self] status in
            guard let self = self else { return }
            self.bottomPlayView.updateStatus(status)
            if status == false {
                self.bottomView.isHidden = false
                self.bottomPlayView.isHidden = true
            }
        }).disposed(by: disposeBag)

        callVM?.currentTime.subscribe(onNext: { [weak self] currentTime in
            guard let self = self else { return }
            bottomPlayView.currentTime(currentTime)
        }).disposed(by: disposeBag)

        callVM?.allTime.subscribe(onNext: { [weak self] allTime in
            guard let self = self else { return }
            bottomPlayView.allTime(allTime)
        }).disposed(by: disposeBag)

        seekDisposable = callVM?.progress.subscribe(onNext: { [weak self] progress in
            guard let self = self else { return }
            bottomPlayView.slider.value = progress
        })

        callVM?.allDuration.subscribe(onNext: { [weak self] duration in
            guard let self = self else { return }
            bottomPlayView.slider.maximumValue = Float(duration)
            bottomPlayView.slider.minimumValue = 0
        }).disposed(by: disposeBag)

        bottomPlayView.slider.rx.controlEvent(.touchUpInside).asObservable().subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            callVM?.seekTo(Double(bottomPlayView.slider.value))
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

        chatView.tableBag?.dispose()

        callVM?.currentPlayIndex.distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] index in
                self?.chatView.scrollToIndex(index)
                JLLogManager.logLevel(.DEBUG, content: "index:\(index)")
            })
            .disposed(by: disposeBag)
        chatView.didSelect = { [weak self] model in
            guard let self = self else { return }
            callVM?.seekTo(model.startTime)
        }
    }

    private func makeSeekDisposable() {
        seekDisposable?.dispose()
        seekDisposable = callVM?.progress.subscribe(onNext: { [weak self] progress in
            guard let self = self else { return }
            bottomPlayView.slider.value = progress
        })
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        callVM?.stop()
        seekDisposable?.dispose()
    }
}
