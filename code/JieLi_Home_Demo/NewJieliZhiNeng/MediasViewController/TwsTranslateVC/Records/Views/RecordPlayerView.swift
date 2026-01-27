//
//  RecordPlayerView.swift
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2025/8/4.
//  Copyright © 2025 杰理科技. All rights reserved.
//

import Foundation

class RecordPlayerView: BasicView {
    let slider = UISlider()
    let controlBtn = UIButton()
    private let currentTimeLab = UILabel()
    private let allTimeLab = UILabel()
    private let topLine = UIView()
    private let orangeColor = UIColor.eHex("#F89514")
    private let blueColor = UIColor.eHex("#448EFF")
    private var currentColor: UIColor!
    private var pauseString: String = "Pause"
    private var pauseImg: String = "icon_pause_yellow"
    private var playString: String = "Play_2"
    private var playImg: String = "icon_play_yellow"

    override func initUI() {
        super.initUI()
        backgroundColor = .white
        addSubview(topLine)
        addSubview(currentTimeLab)
        addSubview(allTimeLab)
        addSubview(slider)
        addSubview(controlBtn)
        currentColor = orangeColor

        topLine.backgroundColor = .eHex("#000000", alpha: 0.08)
        slider.minimumValue = 0
        slider.maximumValue = 100
        slider.minimumTrackTintColor = currentColor
        slider.maximumTrackTintColor = .eHex("#EBEBEB")
        slider.setThumbImage(R.Image.img("icon_slider_thint_yellow"), for: .normal)

        currentTimeLab.textAlignment = .left
        currentTimeLab.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        currentTimeLab.textColor = .eHex("#000000", alpha: 0.6)
        currentTimeLab.adjustsFontSizeToFitWidth = true
        currentTimeLab.text = "00:00"

        allTimeLab.textAlignment = .right
        allTimeLab.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        allTimeLab.textColor = .eHex("#000000", alpha: 0.6)
        allTimeLab.adjustsFontSizeToFitWidth = true
        allTimeLab.text = "00:00"

        controlBtn.setImage(R.Image.img("icon_pause_yellow"), for: .normal)
        controlBtn.backgroundColor = currentColor.withAlphaComponent(0.1)
        controlBtn.layer.cornerRadius = 18
        controlBtn.layer.masksToBounds = true
        controlBtn.setTitle(R.Language.lan("Play_2"), for: .normal)
        controlBtn.setTitleColor(currentColor, for: .normal)
        controlBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 10)
        controlBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        controlBtn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        controlBtn.semanticContentAttribute = .forceLeftToRight
        controlBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)

        topLine.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(0.5)
        }

        slider.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalTo(topLine).offset(8)
        }

        currentTimeLab.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(16)
            make.top.equalTo(slider.snp.bottom).offset(4)
        }

        allTimeLab.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(16)
            make.top.equalTo(slider.snp.bottom).offset(4)
        }

        controlBtn.snp.makeConstraints { make in
            make.top.equalTo(currentTimeLab.snp.bottom)
            make.height.equalTo(36)
            make.width.equalTo(150)
            make.centerX.equalToSuperview()
        }
    }

    func config(
        color: UIColor,
        pointImg: String,
        pauseText: String,
        pauseImg: String,
        playText: String,
        playImg: String
    ) {
        currentColor = color
        slider.minimumTrackTintColor = currentColor
        slider.setThumbImage(R.Image.img(pointImg), for: .normal)
        controlBtn.backgroundColor = currentColor.withAlphaComponent(0.1)
        controlBtn.setTitleColor(currentColor, for: .normal)
        pauseString = pauseText
        self.pauseImg = pauseImg
        playString = playText
        self.playImg = playImg
        updateStatus(true)
    }

    func updateStatus(_ status: Bool) {
        if status {
            controlBtn.setTitle(R.Language.lan(pauseString), for: .normal)
            controlBtn.setImage(R.Image.img(pauseImg), for: .normal)
        } else {
            controlBtn.setTitle(R.Language.lan(playString), for: .normal)
            controlBtn.setImage(R.Image.img(playImg), for: .normal)
        }
    }

    func currentTime(_ time: String) {
        currentTimeLab.text = time
    }

    func allTime(_ time: String) {
        allTimeLab.text = time
    }
}
