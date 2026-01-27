//
//  WeatherView.swift
//  EasyAutoTest
//
//  Created by EzioChan on 2022/8/23.
//  Copyright © 2022 www.zh-jieli.com. All rights reserved.
//

import JLUsefulTools
import UIKit

class WeatherView: UIView, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    let winds: [String] = ["无风向", "东", "南", "西", "北", "东南", "东北", "西北", "西南", "旋转不定"]
    var code: [String] = ["晴", "少云", "晴间多云", "多云", "阴", "有风/和风/清风/微风", "平静", "大风/强风/劲风/疾风", "飓风/狂爆风",
                          "热带风暴/风暴", "霾/中度霾/重度霾/严重霾", "阵雨", "雷阵雨", "雷阵雨并伴有冰雹", "雨/小雨/毛毛雨/细雨/小雨-中雨", "中雨/中雨-大雨", "大雨/大雨-暴雨", "暴雨/暴雨-大暴雨", "大暴雨/大暴雨-特大暴雨", "特大暴雨", "强阵雨", "强雷阵雨", "极端降雨", "雨夹雪/阵雨夹雪/冻雨/雨雪天气", "雪", "阵雪", "小雪/小雪-中雪", "中雪/中雪-大雪", "大雪/大雪-暴雪", "暴雪", "浮尘", "扬沙", "沙尘暴", "强沙尘暴", "龙卷风", "雾/轻雾/浓雾/强浓雾/特强浓雾", "未知", "冷", "未知2"]

    var cityLab = UILabel()
    var cityTxfd = UITextField()
    var provinceLab = UILabel()
    var provinceTxfd = UITextField()
    var temperatureLab = UILabel()
    var temperaturePgv = UISlider()
    var humidityLab = UILabel()
    var humiditySld = UISlider()
    var windlab = UILabel()
    var windView = UISlider()
    var weathercodeLab = UILabel()
    var weathercodePicker = UIPickerView()
    var dateSelectBtn = UIButton()
    var subSwitchLab = UILabel()
    var subSwitch = UISwitch()

    var weatherObjc = JL_MSG_Weather()

    override init(frame: CGRect) {
        super.init(frame: frame)
        weatherObjc.direction = .none
        weatherObjc.code = .typeUnknow
        weatherObjc.temperature = 25
        weatherObjc.humidity = 70
        weatherObjc.wind = 3
        weatherObjc.city = "珠海"
        weatherObjc.province = "广东"
        weatherObjc.date = Date()
        initUI()
    }

    func initUI() {
        addSubview(cityLab)
        cityLab.text = "城市："
        cityLab.adjustsFontSizeToFitWidth = true
        cityLab.snp.makeConstraints { make in
            make.top.equalTo(self.snp.top).offset(0)
            make.left.equalTo(self.snp.left).offset(0)
            make.height.equalTo(30)
            make.width.equalTo(60)
        }

        addSubview(cityTxfd)
        cityTxfd.tag = 0
        cityTxfd.delegate = self
        cityTxfd.borderStyle = .roundedRect
        cityTxfd.text = "珠海"
        cityTxfd.returnKeyType = .done
        cityTxfd.snp.makeConstraints { make in
            make.top.equalTo(self.snp.top).offset(0)
            make.left.equalTo(cityLab.snp.right).offset(2)
            make.height.equalTo(30)
            make.right.equalTo(self.snp.right).offset(0)
        }

        addSubview(provinceLab)
        provinceLab.text = "省份："
        provinceLab.adjustsFontSizeToFitWidth = true
        provinceLab.snp.makeConstraints { make in
            make.top.equalTo(cityLab.snp.bottom).offset(5)
            make.left.equalTo(self.snp.left).offset(0)
            make.height.equalTo(30)
            make.width.equalTo(60)
        }

        addSubview(provinceTxfd)
        provinceTxfd.tag = 1
        provinceTxfd.delegate = self
        provinceTxfd.borderStyle = .roundedRect
        provinceTxfd.text = "广东"
        provinceTxfd.returnKeyType = .done
        provinceTxfd.snp.makeConstraints { make in
            make.top.equalTo(cityTxfd.snp.bottom).offset(5)
            make.left.equalTo(cityLab.snp.right).offset(2)
            make.height.equalTo(30)
            make.right.equalTo(self.snp.right).offset(0)
        }

        addSubview(temperatureLab)
        temperatureLab.text = "温度选择：" + "25"
        temperatureLab.adjustsFontSizeToFitWidth = true
        temperatureLab.snp.makeConstraints { make in
            make.top.equalTo(provinceTxfd.snp.bottom).offset(5)
            make.left.equalTo(self.snp.left).offset(0)
            make.right.equalTo(self.snp.right).offset(0)
            make.height.equalTo(20)
        }
        addSubview(temperaturePgv)
        temperaturePgv.minimumValue = -100
        temperaturePgv.maximumValue = 100
        temperaturePgv.value = 25
        temperaturePgv.tag = 0
        temperaturePgv.addTarget(self, action: #selector(sliderChange(_:)), for: .valueChanged)
        temperaturePgv.snp.makeConstraints { make in
            make.top.equalTo(temperatureLab.snp.bottom).offset(0)
            make.left.equalTo(self.snp.left).offset(8)
            make.right.equalTo(self.snp.right).offset(-8)
            make.height.equalTo(30)
        }

        addSubview(humidityLab)
        humidityLab.text = "湿度选择:70"
        humidityLab.adjustsFontSizeToFitWidth = true
        humidityLab.snp.makeConstraints { make in
            make.top.equalTo(temperaturePgv.snp.bottom).offset(5)
            make.left.equalTo(self.snp.left).offset(0)
            make.right.equalTo(self.snp.right).offset(0)
            make.height.equalTo(20)
        }
        addSubview(humiditySld)
        humiditySld.minimumValue = 0
        humiditySld.maximumValue = 100
        humiditySld.value = 70
        humiditySld.tag = 1
        humiditySld.addTarget(self, action: #selector(sliderChange(_:)), for: .valueChanged)
        humiditySld.snp.makeConstraints { make in
            make.top.equalTo(humidityLab.snp.bottom).offset(0)
            make.left.equalTo(self.snp.left).offset(8)
            make.right.equalTo(self.snp.right).offset(-8)
            make.height.equalTo(30)
        }

        addSubview(windlab)
        windlab.text = "风力等级:3"
        windlab.adjustsFontSizeToFitWidth = true
        windlab.snp.makeConstraints { make in
            make.top.equalTo(humiditySld.snp.bottom).offset(5)
            make.left.equalTo(self.snp.left).offset(0)
            make.right.equalTo(self.snp.right).offset(0)
            make.height.equalTo(20)
        }
        addSubview(windView)
        windView.minimumValue = 0
        windView.maximumValue = 20
        windView.value = 3
        windView.tag = 2
        windView.addTarget(self, action: #selector(sliderChange(_:)), for: .valueChanged)
        windView.snp.makeConstraints { make in
            make.top.equalTo(windlab.snp.bottom).offset(0)
            make.left.equalTo(self.snp.left).offset(8)
            make.right.equalTo(self.snp.right).offset(-8)
            make.height.equalTo(30)
        }

        addSubview(weathercodeLab)
        weathercodeLab.text = "天气类型/风向选择"
        weathercodeLab.adjustsFontSizeToFitWidth = true
        weathercodeLab.snp.makeConstraints { make in
            make.top.equalTo(windView.snp.bottom).offset(0)
            make.left.equalTo(self.snp.left).offset(0)
            make.right.equalTo(self.snp.right).offset(0)
            make.height.equalTo(20)
        }
        addSubview(weathercodePicker)
        weathercodePicker.delegate = self
        weathercodePicker.dataSource = self
        weathercodePicker.tag = 0
        weathercodePicker.snp.makeConstraints { make in
            make.top.equalTo(weathercodeLab.snp.bottom).offset(0)
            make.left.equalTo(self.snp.left).offset(0)
            make.right.equalTo(self.snp.right).offset(0)
            make.height.equalTo(110)
        }

        addSubview(dateSelectBtn)
        addSubview(subSwitchLab)
        addSubview(subSwitch)
        dateSelectBtn.setTitle("日期选择", for: .normal)
        dateSelectBtn.addTarget(self, action: #selector(didSelectDate), for: .touchUpInside)
        dateSelectBtn.backgroundColor = UIColor.systemGreen
        dateSelectBtn.setTitleColor(UIColor.white, for: .normal)
        dateSelectBtn.setTitleColor(UIColor.gray, for: .highlighted)
        dateSelectBtn.layer.cornerRadius = 6
        dateSelectBtn.layer.masksToBounds = true
        dateSelectBtn.snp.makeConstraints { make in
            make.top.equalTo(weathercodePicker.snp.bottom).offset(5)
            make.left.equalTo(self.snp.left).offset(10)
            make.right.equalTo(subSwitchLab.snp.left).offset(-2)
            make.height.equalTo(30)
        }
        subSwitchLab.text = "循环发送:"
        subSwitchLab.adjustsFontSizeToFitWidth = true
        subSwitchLab.snp.makeConstraints { make in
            make.top.equalTo(weathercodePicker.snp.bottom).offset(5)
            make.left.equalTo(dateSelectBtn.snp.right).offset(2)
            make.right.equalTo(subSwitch.snp.left).offset(0)
            make.height.equalTo(30)
            make.width.equalTo(80)
        }

        subSwitch.isOn = false
        subSwitch.snp.makeConstraints { make in
            make.top.equalTo(weathercodePicker.snp.bottom).offset(5)
            make.left.equalTo(subSwitchLab.snp.right).offset(0)
            make.right.equalTo(self.snp.right).offset(-10)
            make.height.equalTo(30)
            make.width.equalTo(50)
        }

        let ges = UITapGestureRecognizer(target: self, action: #selector(endEdit))
        addGestureRecognizer(ges)
    }

    @objc func endEdit() {
        cityTxfd.endEditing(true)
        provinceTxfd.endEditing(true)
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.endEditing(true)
        textfiledSction(textField)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        textfiledSction(textField)
        return true
    }

    func textfiledSction(_ textField: UITextField) {
        if textField.tag == 0 {
            if textField.text?.count ?? 0 < 30 {
                weatherObjc.city = textField.text ?? ""
            } else {
                makeToast("字符长度限制")
            }
        }
        if textField.tag == 1 {
            if textField.text?.count ?? 0 < 30 {
                weatherObjc.province = textField.text ?? ""
            } else {
                makeToast("字符长度限制")
            }
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if pickerView.tag == 0 {
            return 2
        } else {
            return 3
        }
    }

    func pickerView(_: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return winds.count
        } else {
            return code.count
        }
    }

    func pickerView(_: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return winds[row]
        } else {
            return code[row]
        }
    }

    func pickerView(_: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            weatherObjc.direction = JLWindDirectionType(rawValue: UInt8(row)) ?? .none
        } else {
            weatherObjc.code = JLWeatherType(rawValue: UInt8(row)) ?? .typeUnknow
        }
    }

    @objc func sliderChange(_ objc: UISlider) {
        if objc.tag == 0 {
            weatherObjc.temperature = Int(objc.value)
            temperatureLab.text = "温度选择：" + String(Int(objc.value))
        }
        if objc.tag == 1 {
            weatherObjc.humidity = Int(objc.value)
            humidityLab.text = "湿度选择:" + String(Int(objc.value))
        }
        if objc.tag == 2 {
            weatherObjc.wind = Int(objc.value)
            windlab.text = "风力等级:" + String(Int(objc.value))
        }
    }

    @objc func didSelectDate() {
        let fmStr = "yyyy-MM-dd HH:mm:ss"
        let fm = DateFormatter()
        fm.dateFormat = fmStr
        _ = Dialog().wTitleSet()("日期选择器")
            .wEventOKFinishSet()({ _, otherData in

                let dateStr = otherData as! String

                self.weatherObjc.date = fm.date(from: dateStr) ?? Date()

            }).wDefaultDateSet()(Date())
            .wDateTimeTypeSet()(fmStr)
            .wPickRepeatSet()(true)
            .wTypeSet()(DialogTypeDatePicker)
            .wMessageFontSet()(16)
            .wStart()
    }
}
