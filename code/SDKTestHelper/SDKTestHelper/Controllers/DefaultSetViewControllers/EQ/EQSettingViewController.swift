//
//  EQSettingViewController.swift
//  WatchTest
//
//  Created by 杰理科技 on 2023/11/24.
//

import UIKit

class EQSettingViewController: BaseViewController {
    @IBOutlet var eqName: UILabel!

    @IBOutlet var sld_0: UISlider!
    @IBOutlet var sld_1: UISlider!
    @IBOutlet var sld_2: UISlider!
    @IBOutlet var sld_3: UISlider!
    @IBOutlet var sld_4: UISlider!
    @IBOutlet var sld_5: UISlider!
    @IBOutlet var sld_6: UISlider!
    @IBOutlet var sld_7: UISlider!
    @IBOutlet var sld_8: UISlider!
    @IBOutlet var sld_9: UISlider!

    @IBOutlet var lb_0: UILabel!
    @IBOutlet var lb_1: UILabel!
    @IBOutlet var lb_2: UILabel!
    @IBOutlet var lb_3: UILabel!
    @IBOutlet var lb_4: UILabel!
    @IBOutlet var lb_5: UILabel!
    @IBOutlet var lb_6: UILabel!
    @IBOutlet var lb_7: UILabel!
    @IBOutlet var lb_8: UILabel!
    @IBOutlet var lb_9: UILabel!

    var mManager: JL_ManagerM?
    var mSystemEQ: JL_SystemEQ?

    override func viewDidLoad() {
        super.viewDidLoad()

        /*--- 引用EQ数据类 ---*/
        mManager = BleManager.shared.currentCmdMgr
        mSystemEQ = BleManager.shared.currentCmdMgr?.mSystemEQ

        mSystemEQ?.cmdGet { [weak self] status, model in
            if status == .success {
                JL_Tools.mainTask {
                    self?.updateEQUI(model!)
                }
            }
        }
    }

    override func initUI() {
        super.initUI()
        navigationView.title = R.localStr.eqSetting()
        navigationView.leftBtn.setTitle(R.localStr.back(), for: .normal)
    }

    override func initData() {
        super.initData()
        navigationView.leftBtn.rx.tap.subscribe { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }.disposed(by: disposeBag)
    }

    func updateEQUI(_ systemEQ: JL_SystemEQ) {
        eqName.text = updateEqName(model: systemEQ.eqMode)

        for i in 0 ... 9 {
            let lb_eq = pickEqLabel(i)
            let lb_frq = pickFrqLabel(i)
            let sld = pickSlider(i)
            lb_eq?.text = ""
            lb_frq?.text = ""

            sld?.value = 0
            sld?.minimumTrackTintColor = UIColor.lightGray
            sld?.isUserInteractionEnabled = false
        }

        if systemEQ.eqArray.count == 0 ||
            systemEQ.eqFrequencyArray.count == 0 { return }

        for i in 0 ... systemEQ.eqArray.count - 1 {
            let lb = pickEqLabel(i)
            lb?.text = "\(systemEQ.eqArray[i])"

            let sld = pickSlider(i)
            sld?.minimumTrackTintColor = UIColor.link
            sld?.value = Float(truncating: systemEQ.eqArray[i] as! NSNumber)

            if systemEQ.eqMode == .CUSTOM { sld?.isUserInteractionEnabled = true }
        }

        for i in 0 ... systemEQ.eqFrequencyArray.count - 1 {
            let lb = pickFrqLabel(i)
            lb?.text = "\(systemEQ.eqFrequencyArray[i])"
        }
    }

    @IBAction func onSelectFrq(_: UISlider) {
        let arr = [sld_0.value, sld_1.value, sld_2.value, sld_3.value, sld_4.value,
                   sld_5.value, sld_6.value, sld_7.value, sld_8.value, sld_9.value]
        let ct = mSystemEQ?.eqArray.count
        var eqArr = [NSNumber]()

        for value in arr.prefix(ct!) {
            eqArr.append(NSNumber(value: Int(value)))
        }
        mSystemEQ?.cmdSetSystemEQ(.CUSTOM, params: eqArr)
    }

    @IBAction func onSelectEQ(_ sender: UIButton) {
        let mode = JL_EQMode(rawValue: UInt8(sender.tag))!
        eqName.text = updateEqName(model: mode)
        mSystemEQ?.cmdSetSystemEQ(mode, params: nil)

        JL_Tools.delay(1.0) {
            self.mSystemEQ?.cmdGet { [weak self] status, model in
                if status == .success {
                    JL_Tools.mainTask {
                        self?.updateEQUI(model!)
                    }
                }
            }
        }
    }

    func updateEqName(model: JL_EQMode) -> String {
        if model == .NORMAL { return R.localStr.natural() }
        if model == .ROCK { return R.localStr.rock() }
        if model == .POP { return R.localStr.pop() }
        if model == .CLASSIC { return R.localStr.classic() }
        if model == .JAZZ { return R.localStr.jazz() }
        if model == .COUNTRY { return R.localStr.country() }
        if model == .CUSTOM { return R.localStr.custom() }
        if model == .LATIN { return R.localStr.latin() }
        if model == .DANCE { return R.localStr.dance() }
        return ""
    }

    func pickEqLabel(_ index: NSInteger) -> UILabel? {
        for view in view.subviews {
            if view.isKind(of: UILabel.self) {
                if view.tag == index {
                    return view as? UILabel
                }
            }
        }
        return nil
    }

    func pickFrqLabel(_ index: NSInteger) -> UILabel? {
        for view in view.subviews {
            if view.isKind(of: UILabel.self) {
                if view.tag == index + 10 {
                    return view as? UILabel
                }
            }
        }
        return nil
    }

    func pickSlider(_ index: NSInteger) -> UISlider? {
        for view in view.subviews {
            if view.isKind(of: UISlider.self) {
                if view.tag == index {
                    return view as? UISlider
                }
            }
        }
        return nil
    }
}
