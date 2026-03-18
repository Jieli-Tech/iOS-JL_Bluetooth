//
//  QRScanerViewController.swift
//  JieLiAuracastAssistant
//
//  Created by EzioChan on 2024/9/28.
//

import AVFoundation
import Photos
import UIKit

class QRScanerViewController: BaseViewController, AVCaptureMetadataOutputObjectsDelegate {
    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var flashLightBtn = UIButton()
    private var albumBtn = UIButton()
    private lazy var imagePicker: UIImagePickerController = {
        let picker = UIImagePickerController()
        picker.delegate = self
        return picker
    }()

    var handleScanResult: ((String) -> Void)?

    override func initUI() {
        navigationView.title = "Scan QR Code"
        navigationView.titleLab.textColor = .white
        navigationView.leftBtn.setTitle(R.localStr.back(), for: .normal)
        view.addSubview(albumBtn)
        view.addSubview(flashLightBtn)
        view.backgroundColor = .clear

        albumBtn.setImage(R.image.scan_icon_photo(), for: .normal)
        flashLightBtn.setImage(R.image.scan_icon_flashlight(), for: .normal)

        flashLightBtn.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(72)
            make.bottom.equalToSuperview().inset(self.view.safeAreaInsets.bottom + 64)
            make.width.height.equalTo(48)
        }

        albumBtn.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(72)
            make.bottom.equalToSuperview().inset(self.view.safeAreaInsets.bottom + 64)
            make.width.height.equalTo(48)
        }
    }

    override func initData() {
        super.initData()

        checkCameraPermissionStatus()

        navigationView.leftBtn.rx.tap.subscribe(onNext: { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }).disposed(by: disposeBag)

        albumBtn.rx.tap.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            PHPhotoLibrary.requestAuthorization { status in
                DispatchQueue.main.async {
                    if status == .authorized {
                        self.imagePicker.sourceType = .photoLibrary
                        self.present(self.imagePicker, animated: true, completion: nil)
                    } else {
                        JLLogManager.logLevel( .INFO, content: "user reject photo library")
                        self.showSettingsAlert()
                    }
                }
            }
        }).disposed(by: disposeBag)

        flashLightBtn.rx.tap.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            guard let inputDevice = captureSession.inputs.first as? AVCaptureDeviceInput else {
                self.checkCameraPermissionStatus()
                return
            }
            do {
                try inputDevice.device.lockForConfiguration()
                inputDevice.device.torchMode = inputDevice.device.torchMode == .on ? .off : .on
                inputDevice.device.unlockForConfiguration()
            } catch {
                JLLogManager.logLevel( .INFO, content: error.localizedDescription)
            }
        }).disposed(by: disposeBag)
    }

    private func setupCaptureSession() {
        captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video),
              let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice) else { return }

        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)

            DispatchQueue.main.async { [self] in
                let metadataOutput = AVCaptureMetadataOutput()

                if captureSession.canAddOutput(metadataOutput) {
                    captureSession.addOutput(metadataOutput)

                    metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                    metadataOutput.metadataObjectTypes = [.qr]

                    previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                    previewLayer?.frame = view.layer.bounds
                    previewLayer?.videoGravity = .resizeAspectFill
                    view.layer.insertSublayer(previewLayer!, at: 0)
                    DispatchQueue.global().async { [self] in
                        captureSession.startRunning()
                    }
                }
            }
        }
    }

    private func checkCameraPermissionStatus() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        DispatchQueue.main.async {
            switch status {
            case .authorized:
                // 摄像头权限已经被授权
                JLLogManager.logLevel( .INFO, content: "Camera permission is granted.")
                self.setupCaptureSession()
            case .denied:
                // 摄像头权限已被拒绝
                JLLogManager.logLevel( .INFO, content: "Camera permission was denied.")
                // 你可以提示用户前往设置页面开启权限
                self.showSettingsAlert()
            case .restricted:
                // 摄像头权限受到限制（例如在家长控制模式下）
                JLLogManager.logLevel( .INFO, content: "Camera access is restricted.")
                self.showSettingsAlert()
            case .notDetermined:
                // 摄像头权限尚未请求
                JLLogManager.logLevel( .INFO, content: "Camera permission not yet determined.")
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    DispatchQueue.main.async {
                        if granted {
                            JLLogManager.logLevel( .INFO, content: "Camera permission granted.")
                            self.setupCaptureSession()
                        } else {
                            JLLogManager.logLevel( .INFO, content: "Camera permission not granted.")
                            // 摄像头权限请求被拒绝
                            self.showSettingsAlert()
                        }
                    }
                }
            @unknown default:
                // 处理未知的情况
                JLLogManager.logLevel( .INFO, content: "Unknown camera permission status.")
                self.showSettingsAlert()
            }
        }
    }

    private func showSettingsAlert() {
        let message = "Please go to [Application Management]->[Permission Management] to allow permissions"
        let alertController = UIAlertController(title: "Missing Permissions",
                                                message: message,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: R.localStr.oK(), style: .default, handler: { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }))
        alertController.addAction(UIAlertAction(title: R.localStr.cancel(), style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }

    // MARK: - AVCaptureMetadataOutputObjectsDelegate

    func metadataOutput(_: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from _: AVCaptureConnection) {
        captureSession.stopRunning()
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
                  let stringValue = readableObject.stringValue else { return }

            JLLogManager.logLevel( .INFO, content: "Scanned QR Code: \(stringValue)")
            if handleScanResult != nil {
                handleScanResult?(stringValue)
                handleScanResult = nil
            } else {
                DispatchQueue.global().async { [weak self] in
                    guard let self = self else {
                        return
                    }
                    self.captureSession.startRunning()
                }
            }
        }
    }
}

extension QRScanerViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_: UIImagePickerController) {
        dismiss(animated: true)
    }

    func imagePickerController(_: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        dismiss(animated: true)
        if let image = info[.originalImage] as? UIImage {
            let ciImage = CIImage(image: image)!
            let context = CIContext(options: nil)
            let detector = CIDetector(ofType: CIDetectorTypeQRCode,
                                      context: context,
                                      options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])

            guard let features = detector?.features(in: ciImage) as? [CIQRCodeFeature], features.count > 0 else {
                JLLogManager.logLevel( .INFO, content: "No QR codes found.")
                AppDelegate.getCurrentWindows()?.makeToast("Failed to load QR code", position: .center)
                return
            }
            for feature in features {
                if let qrCodeData = feature.messageString {
                    JLLogManager.logLevel( .INFO, content: "QR Code Data: \(qrCodeData)")
                    handleScanResult?(qrCodeData)
                }
            }
        }
    }
}
