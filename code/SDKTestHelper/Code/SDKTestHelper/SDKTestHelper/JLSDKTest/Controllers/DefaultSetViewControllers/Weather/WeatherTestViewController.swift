//
//  WeatherTestViewController.swift
//  EasyAutoTest
//
//  Created by EzioChan on 2022/8/23.
//  Copyright © 2022 www.zh-jieli.com. All rights reserved.
//

import UIKit

class WeatherTestViewController: BaseViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    var selecterView = WeatherView(frame: CGRect.zero)

    var sendBtn = UIButton()
    var pickerViewLab = UILabel()
    var sendPickerView = UIPickerView()

    private let timeSecs = [1, 3, 5, 7]
    private var timeLoops: [Int] = []

    private var timeSender = Timer()
    private var sendNumber: Int = 1
    private var sendSec = 1

    private var isSendding = false
    private var proList = ["北京", "天津", "河  北", "山  西", "内蒙古", "辽  宁", "吉  林", "黑龙江", "上  海", "江  苏", "浙  江", "安  徽", "福  建", "江  西", "山  东", "河  南", "湖  北", "湖  南", "广  东", "广  西", "海  南", "重  庆", "四  川", "贵  州", "云  南", "西  藏", "陕  西", "甘  肃", "青  海", "宁  夏", "新  疆", "香  港", "澳  门", "台  湾"]

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func initUI() {
        super.initUI()

        navigationView.title = R.localStr.weatherTest()
        navigationView.leftBtn.setTitle(R.localStr.back(), for: .normal)

        view.addSubview(selecterView)
        selecterView.snp.makeConstraints { make in
            make.top.equalTo(navigationView.snp.bottom).offset(10)
            make.left.equalTo(self.view.snp.left).offset(10)
            make.right.equalTo(self.view.snp.right).offset(-10)
            make.height.equalTo(410)
        }

        view.addSubview(sendBtn)
        sendBtn.setTitle("send/start", for: .normal)
        sendBtn.addTarget(self, action: #selector(didSend), for: .touchUpInside)
        sendBtn.backgroundColor = UIColor.systemBlue
        sendBtn.setTitleColor(UIColor.white, for: .normal)
        sendBtn.setTitleColor(UIColor.gray, for: .highlighted)
        sendBtn.layer.cornerRadius = 6
        sendBtn.layer.masksToBounds = true
        sendBtn.snp.makeConstraints { make in
            make.top.equalTo(selecterView.snp.bottom).offset(5)
            make.left.equalTo(self.view.snp.left).offset(20)
            make.right.equalTo(self.view.snp.right).offset(-20)
            make.height.equalTo(40)
        }

        view.addSubview(pickerViewLab)
        pickerViewLab.text = "Time intertal"
        pickerViewLab.adjustsFontSizeToFitWidth = true
        pickerViewLab.snp.makeConstraints { make in
            make.top.equalTo(sendBtn.snp.bottom).offset(0)
            make.left.equalTo(self.view.snp.left).offset(0)
            make.right.equalTo(self.view.snp.right).offset(0)
            make.height.equalTo(20)
        }
        view.addSubview(sendPickerView)
        sendPickerView.delegate = self
        sendPickerView.dataSource = self
        sendPickerView.tag = 0
        sendPickerView.snp.makeConstraints { make in
            make.top.equalTo(pickerViewLab.snp.bottom).offset(0)
            make.left.equalTo(self.view.snp.left).offset(0)
            make.right.equalTo(self.view.snp.right).offset(0)
            make.height.equalTo(100)
        }
    }

    override func initData() {
        super.initData()
        for item in 1 ... 100 {
            timeLoops.append(item)
        }
        navigationView.leftBtn.rx.tap.subscribe(onNext: { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }).disposed(by: disposeBag)
    }

    @objc func exitBtnInside() {
        dismiss(animated: true, completion: nil)
        timeSender.invalidate()
        sendBtn.setTitle("send/start", for: .normal)
        sendBtn.backgroundColor = UIColor.systemBlue
    }

    @objc func didSend() {
        if isSendding == true && selecterView.subSwitch.isOn == true {
            timeSender.invalidate()
            sendBtn.setTitle("send/start", for: .normal)
            sendBtn.backgroundColor = UIColor.systemBlue
            return
        }
        sendBtn.setTitle("sending...", for: .normal)
        sendBtn.backgroundColor = UIColor.gray

        if selecterView.subSwitch.isOn == true {
            timeSender.invalidate()
            timeSender = Timer.scheduledTimer(timeInterval: TimeInterval(sendSec), target: self, selector: #selector(sendAction), userInfo: nil, repeats: true)
            timeSender.fire()

        } else {
            isSendding = true
            JLWearable.sharedInstance().w_syncWeather(selecterView.weatherObjc, withEntity: BleManager.shared.currentEntity!) { status in
                self.isSendding = false
                self.sendBtn.setTitle("send/start", for: .normal)
                self.sendBtn.backgroundColor = UIColor.systemBlue
                if !status {
                    self.view.makeToast("send success")
                } else {
                    self.view.makeToast("send fail")
                }
            }
        }
    }

    @objc func sendAction() {
        sendNumber -= 1
        if sendNumber < 0 {
            isSendding = false
            sendBtn.setTitle("send/start", for: .normal)
            sendBtn.backgroundColor = UIColor.systemBlue
            timeSender.invalidate()
            view.makeToast("send over")
            return
        }
        sendBtn.setTitle("sending(random)", for: .normal)
        sendBtn.backgroundColor = UIColor.gray
        isSendding = true

        let weather = JL_MSG_Weather()
        weather.city = "random city name"
        weather.code = .typeExtraordinaryRainstorm
        let index = Int(arc4random() % UInt32(proList.count))
        weather.province = proList[index]
        weather.temperature = Int(arc4random() % 100)
        weather.humidity = Int(arc4random() % 100)
        weather.direction = .south
        weather.wind = Int(arc4random() % 20)
        weather.date = Date()

        JLWearable.sharedInstance().w_syncWeather(weather, withEntity: BleManager.shared.currentEntity!) { _ in
            self.isSendding = false
        }
    }

    func numberOfComponents(in _: UIPickerView) -> Int {
        return 2
    }

    func pickerView(_: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return timeSecs.count
        }
        return timeLoops.count
    }

    func pickerView(_: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return String(timeSecs[row])
        }
        return String(timeLoops[row])
    }

    func pickerView(_: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            sendSec = timeSecs[row]
        } else {
            sendNumber = timeLoops[row]
        }
    }
}
