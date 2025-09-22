//
//  DialTpViewController.swift
//  WatchTest
//
//  Created by EzioChan on 2023/11/2.
//

import JLBmpConvertKit
import UIKit

class DialTpViewController: BaseViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    let seleteFileBtn = UIButton()
    let seleteImageFileBtn = UIButton()
    let transpFileLab = UILabel()
    let progress = UIProgressView()
    let progressLab = UILabel()
    let cancelBtn = UIButton()
    let startBtn = UIButton()
    let transpView = FileLoadView()
    let deviceFileListView = UITableView()
    let dialsArray = BehaviorRelay<[String]>(value: [])

    var filePath: String = ""
    var isDial = false
    private var watchName = ""
    private var watchBinName = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        requestData()
    }

    override func initUI() {
        super.initUI()
        navigationView.title = R.localStr.dialTransmission()
        navigationView.leftBtn.setTitle(R.localStr.back(), for: .normal)

        seleteFileBtn.setTitle(R.localStr.selectDial(), for: .normal)
        seleteFileBtn.backgroundColor = UIColor.random()
        seleteFileBtn.setTitleColor(UIColor.white, for: .normal)
        seleteFileBtn.layer.cornerRadius = 6
        seleteFileBtn.layer.masksToBounds = true
        seleteFileBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        seleteImageFileBtn.setTitle(R.localStr.selectBackground(), for: .normal)
        seleteImageFileBtn.backgroundColor = UIColor.random()
        seleteImageFileBtn.setTitleColor(UIColor.white, for: .normal)
        seleteImageFileBtn.layer.cornerRadius = 6
        seleteImageFileBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        seleteImageFileBtn.layer.masksToBounds = true

        transpFileLab.text = R.localStr.noFileSelected()
        transpFileLab.textColor = UIColor.black
        transpFileLab.font = UIFont.boldSystemFont(ofSize: 15)
        transpFileLab.textAlignment = .center

        cancelBtn.setTitle(R.localStr.cancel(), for: .normal)
        cancelBtn.backgroundColor = UIColor.random()
        cancelBtn.setTitleColor(UIColor.white, for: .normal)
        cancelBtn.layer.cornerRadius = 6
        cancelBtn.layer.masksToBounds = true

        startBtn.setTitle(R.localStr.start(), for: .normal)
        startBtn.backgroundColor = UIColor.random()
        startBtn.setTitleColor(UIColor.white, for: .normal)
        startBtn.layer.cornerRadius = 6
        startBtn.layer.masksToBounds = true

        progress.progressTintColor = UIColor.red
        progress.trackTintColor = UIColor.lightGray
        progress.progress = 0

        progressLab.text = "0%"
        progressLab.textColor = UIColor.black
        progressLab.font = UIFont.systemFont(ofSize: 15)
        progressLab.textAlignment = .center

        view.addSubview(seleteFileBtn)
        view.addSubview(seleteImageFileBtn)
        view.addSubview(transpFileLab)
        view.addSubview(progress)
        view.addSubview(progressLab)
        view.addSubview(cancelBtn)
        view.addSubview(startBtn)
        view.addSubview(deviceFileListView)
        view.addSubview(transpView)

        seleteFileBtn.snp.makeConstraints { make in
            make.top.equalTo(navigationView.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(16)
            make.right.equalTo(seleteImageFileBtn.snp.left).offset(-10)
            make.width.equalTo(seleteImageFileBtn)
            make.height.equalTo(50)
        }

        seleteImageFileBtn.snp.makeConstraints { make in
            make.top.equalTo(navigationView.snp.bottom).offset(10)
            make.left.equalTo(seleteFileBtn.snp.right).offset(10)
            make.right.equalToSuperview().inset(16)
            make.width.equalTo(seleteFileBtn)
            make.height.equalTo(50)
        }

        transpFileLab.snp.makeConstraints { make in
            make.top.equalTo(seleteFileBtn.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(25)
        }

        progress.snp.makeConstraints { make in
            make.top.equalTo(transpFileLab.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(4)
        }
        progressLab.snp.makeConstraints { make in
            make.top.equalTo(progress.snp.bottom).offset(5)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(25)
        }

        startBtn.snp.makeConstraints { make in
            make.top.equalTo(progressLab.snp.bottom).offset(20)
            make.left.equalToSuperview().inset(16)
            make.right.equalTo(cancelBtn.snp.left).offset(-16)
            make.width.equalTo(cancelBtn.snp.width)
            make.height.equalTo(50)
        }
        cancelBtn.snp.makeConstraints { make in
            make.top.equalTo(progressLab.snp.bottom).offset(20)
            make.right.equalToSuperview().inset(16)
            make.left.equalTo(startBtn.snp.right).offset(16)
            make.width.equalTo(startBtn.snp.width)
            make.height.equalTo(50)
        }

        deviceFileListView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(startBtn.snp.bottom).offset(20)
        }

        deviceFileListView.register(UITableViewCell.self,
                                    forCellReuseIdentifier: "DialFileCell")

        dialsArray.bind(to: deviceFileListView.rx.items(cellIdentifier: "DialFileCell")) { _, element, cell in

            cell.textLabel?.text = element

        }.disposed(by: disposeBag)

        deviceFileListView.rx.itemDeleted.subscribe { [weak self] indexPath in
            guard let strongSelf = self else { return }
            let path = strongSelf.dialsArray.value[indexPath.row]
            DialManager.deleteFile(path) { st, _ in
                if st == .success {
                    strongSelf.view.makeToast(R.localStr.deleteSuccess(), position: .center)
                    strongSelf.requestData()
                }
            }
        }.disposed(by: disposeBag)

        transpView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        transpView.isHidden = true
    }

    override func initData() {
        super.initData()
        navigationView.leftBtn.rx.tap.subscribe { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }.disposed(by: disposeBag)

        transpView.handleBlock = { [weak self] path in
            self?.transpView.isHidden = true
            self?.filePath = path
            self?.transpFileLab.text = (path as NSString).lastPathComponent
            self?.isDial = true
        }

        seleteFileBtn.rx.tap.subscribe { [weak self] _ in
            self?.transpView.isHidden = false
            self?.transpView.showFiles(_R.path.watchFilePath)
        }.disposed(by: disposeBag)

        seleteImageFileBtn.rx.tap.subscribe { [weak self] _ in
            self?.showTransportWatchBg()
        }.disposed(by: disposeBag)

        startBtn.rx.tap.subscribe { [weak self] _ in
            guard let strongSelf = self, strongSelf.filePath != "" else { return }
            if strongSelf.isDial {
                strongSelf.handleTransport()
            } else {
                strongSelf.handleTransportWatchBg()
            }
        }.disposed(by: disposeBag)

        cancelBtn.rx.tap.subscribe { [weak self] _ in
            BleManager.shared.currentCmdMgr?.mFileManager.cmdStopBigFileData()
            self?.startBtn.setTitleColor(UIColor.black, for: .normal)
            self?.startBtn.isUserInteractionEnabled = true
        }.disposed(by: disposeBag)

        deviceFileListView.rx.modelDeleted(String.self).subscribe { [weak self] item in
            if let _ = BleManager.shared.currentCmdMgr {
                DialManager.deleteFile("/" + item) { op, _ in
                    if op == .success {
                        self?.view.makeToast(R.localStr.deletionOfWatchDialSuccessful(),
                                             position: .center)
                        self?.requestData()
                    }
                }
            }
        }.disposed(by: disposeBag)
    }

    func requestData() {
        DialManager.listFile { type, list in
            if type == .success {
                let targetList = list as? [String] ?? []
                self.dialsArray.accept(targetList)
            }
        }
    }

    func handleTransport() {
        let fileName = "/" + (filePath as NSString).lastPathComponent.uppercased()

        guard let dt = try? Data(contentsOf: URL(fileURLWithPath: filePath)) else {
            return
        }
        DialManager.addFile(fileName, content: dt) { [weak self] op, progress in

            guard let self = self else { return }

            switch op {
            case .noSpace:
                self.view.makeToast(R.localStr.notEnoughSpace(), position: .center)
            case .doing:
                self.view.makeToast(R.localStr.transmitting(), position: .center)
                self.progress.progress = Float(progress)
                self.progressLab.text = "\(Int(progress * 100))%"
            case .fail:
                self.view.makeToast(R.localStr.transportError(), position: .center)
            case .success:
                self.view.makeToast(R.localStr.transportedSuccessfully(), position: .center)
                BleManager.shared.currentCmdMgr?.mFlashManager
                    .cmdWatchFlashPath(fileName, flag: .setDial, result: {
                        flash, _, _, _ in
                        if flash != 0 {
                            self.view.makeToast(R.localStr.theDialFileSettingFailedCheckTheReliabilityOfTheDialFile())
                        }
                        self.requestData()
                    })
            case .unnecessary:
                self.view.makeToast(R.localStr.noNeedToTransmit(), position: .center)
            case .resetFial:
                self.view.makeToast(R.localStr.resetFailed(), position: .center)
            case .normal:
                self.view.makeToast(R.localStr.regular(), position: .center)
            case .cmdFail:
                self.view.makeToast(R.localStr.commandExecutionFailed(), position: .center)
            @unknown default:
                break
            }
        }
    }

    func handleTransportWatchBg() {
        let binPath = JL_Tools.listPath(.libraryDirectory,
                                        middlePath: "",
                                        file: watchBinName)
        guard let dt = try? Data(contentsOf: URL(fileURLWithPath: binPath)) else {
            return
        }
        DialManager.addFile("/" + watchBinName, content: dt) {
            [weak self] op, progress in
            guard let self = self else { return }

            switch op {
            case .noSpace:
                self.view.makeToast(R.localStr.notEnoughSpace(), position: .center)
            case .doing:
                self.view.makeToast(R.localStr.transmitting(), position: .center)
                self.progress.progress = Float(progress)
                self.progressLab.text = "\(Int(progress * 100))%"
            case .fail:
                self.view.makeToast(R.localStr.transportError(), position: .center)
            case .success:
                self.view.makeToast(R.localStr.transportedSuccessfully(), position: .center)

                BleManager.shared.currentCmdMgr?.mFlashManager
                    .cmdWatchFlashPath("/" + self.watchBinName,
                                       flag: .activateCustomDial,
                                       result: { _, _, _, _ in
                                           self.requestData()
                                       })
            case .unnecessary:
                self.view.makeToast(R.localStr.noNeedToTransmit(), position: .center)
            case .resetFial:
                self.view.makeToast(R.localStr.resetFailed(), position: .center)
            case .normal:
                self.view.makeToast(R.localStr.regular(), position: .center)
            case .cmdFail:
                self.view.makeToast(R.localStr.commandExecutionFailed(), position: .center)
            @unknown default:
                break
            }
        }
    }

    func showTransportWatchBg() {
        // get current watch dial
        BleManager.shared.currentCmdMgr?.mFlashManager
            .cmdWatchFlashPath(nil,
                               flag: .readCurrentDial,
                               result: { [weak self] _, _, path, _ in
                                   guard let self = self else { return }
                                   self.watchName = path ?? ""
                                   self.watchBinName = self.newBgName(name: self.watchName)
                                   ECPrintDebug("watchName:\(self.watchName)\nwatchBinName:\(self.watchBinName)", self, "\(#function)", #line)
                                   DispatchQueue.main.async {
                                       self.makePhoto()
                                   }
                               })
    }

    func makePhoto() {
        let imgVc = UIImagePickerController()
        imgVc.delegate = self
        let alert = UIAlertController(title: R.localStr.select(),
                                      message: nil,
                                      preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: R.localStr.camera(),
                                      style: .default,
                                      handler: { [weak self] _ in
                                          imgVc.sourceType = .camera
                                          imgVc.cameraDevice = .rear
                                          self?.present(imgVc, animated: true, completion: nil)
                                      }))
        alert.addAction(UIAlertAction(title: R.localStr.album(),
                                      style: .default,
                                      handler: { [weak self] _ in
                                          imgVc.sourceType = .photoLibrary
                                          self?.present(imgVc, animated: true, completion: nil)
                                      }))
        alert.addAction(UIAlertAction(title: R.localStr.cancel(),
                                      style: .cancel,
                                      handler: nil))
        present(alert, animated: true)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any])
    {
        picker.dismiss(animated: true)
        let image = info[.originalImage] as? UIImage
        if let model = BleManager.shared.currentCmdMgr?.outputDeviceModel() {
            let w = CGFloat(model.flashInfo.mScreenWidth)
            let h = CGFloat(model.flashInfo.mScreenHeight)
            let size = CGSize(width: w, height: h)
            let dt = JLBmpConvert.resize(image!, andResizeTo: size)
            changeImageToBin(dt)
            transpFileLab.text = watchBinName
            isDial = false
        }
    }

    func changeImageToBin(_ dt: Data) {
        let bmpPath = JL_Tools.listPath(.libraryDirectory,
                                        middlePath: "",
                                        file: "iOS_test.bmp")
        let binPath = JL_Tools.listPath(.libraryDirectory,
                                        middlePath: "",
                                        file: watchBinName)
        JL_Tools.removePath(bmpPath)
        JL_Tools.removePath(binPath)

        JL_Tools.create(on: .libraryDirectory,
                        middlePath: "",
                        file: "iOS_test.bmp")
        JL_Tools.create(on: .libraryDirectory,
                        middlePath: "",
                        file: watchBinName)

        JL_Tools.write(dt, fillFile: bmpPath)

        let model = BleManager.shared.currentCmdMgr?.outputDeviceModel()

        let option = JLBmpConvertOption()
        if model?.sdkType == .type701xWATCH {
            option.convertType = .type701N_RBG
            let _ = JLBmpConvert.convert(option, inFilePath: bmpPath, outFilePath: binPath)
        } else if model?.sdkType == .type707nWATCH {
            option.convertType = .type707N_ARGB
            // 当前只有 707N 支持指定图像格式
            option.pixelformat = ._565
            let _ = JLBmpConvert.convert(option, inFilePath: bmpPath, outFilePath: binPath)
        } else {
            option.convertType = .type695N_RBG
            let _ = JLBmpConvert.convert(option, inFilePath: bmpPath, outFilePath: binPath)
        }
        filePath = binPath
    }
}


extension DialTpViewController {
    func newBgName(name: String) -> String {
        var wName = name.replacingOccurrences(of: "/", with: "")
        if wName == "WATCH" {
            wName = "BGP_W000"
        } else {
            let num = wName.replacingOccurrences(of: "WATCH", with: "")
            if num.count == 1 {
                wName = "BGP_W00\(num)"
            }
            if num.count == 2 {
                wName = "BGP_W0\(num)"
            }
            if num.count == 3 {
                wName = "BGP_W\(num)"
            }
        }
        return wName
    }
}
