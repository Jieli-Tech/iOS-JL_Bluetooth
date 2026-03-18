//
//  ResPackageViewModel.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2026/3/18.
//  Copyright © 2026 www.zh-jieli.com. All rights reserved.
//
import Foundation
import RxSwift
import RxCocoa
import JLBmpConvertKit
import JLPackageResKit
import JL_BLEKit

enum ResPackageState {
    case idle
    case converting(progress: Float, current: Int, total: Int)
    case packing
    case transferring(progress: Float)
    case success(message: String)
    case failed(step: String, error: String)
}

struct ResImageItem {
    let url: URL
    let filename: String
    let size: UInt64
    let thumbnail: UIImage?
}

class ResPackageViewModel {
    
    // Output
    let state = BehaviorRelay<ResPackageState>(value: .idle)
    let selectedImages = BehaviorRelay<[ResImageItem]>(value: [])
    let packageFileUrl = BehaviorRelay<URL?>(value: nil)
    
    // Configs
    var mode: JLBmpConvertType = .type701N_ARBG
    var packageType: JLBmpPixelformat = ._Auto
    var packetFormat: JLBmpPacketFormat = .JLUI
    var targetFileName: String = "PKG_001"
    
    private let disposeBag = DisposeBag()
    private var dialMgr: JLDialUnitMgr?
    
    // Caches
    private var currentSessionUUID = UUID().uuidString
    
    init() {
        initDialMgr()
    }
    
    private func initDialMgr() {
        guard let mgr = BleManager.shared.currentCmdMgr else { return }
        dialMgr = JLDialUnitMgr(manager: mgr, completion: { [weak self] err in
            if let err = err {
                self?.state.accept(.failed(step: "BLE Init", error: err.localizedDescription))
            }
            mgr.mFileManager.setCurrentFileHandleType(.FLASH)
        })
    }
    
    func selectImages(urls: [URL]) {
        var items: [ResImageItem] = selectedImages.value
        for url in urls {
            guard url.pathExtension.lowercased() == "png" else { continue }
            if items.count >= 10 { break } // Max 10
            
            let size = _R.sizeForFilePath(url.path)
            if size > 2 * 1024 * 1024 { continue } // Max 2MB
            
            if items.contains(where: { $0.url == url }) { continue }
            
            let image = UIImage(contentsOfFile: url.path)
            let item = ResImageItem(url: url, filename: url.lastPathComponent, size: size, thumbnail: image)
            items.append(item)
        }
        selectedImages.accept(items)
    }
    
    func removeImage(at index: Int) {
        var items = selectedImages.value
        if index < items.count {
            items.remove(at: index)
            selectedImages.accept(items)
        }
    }
    
    func startProcess() {
        let items = selectedImages.value
        guard !items.isEmpty else {
            state.accept(.failed(step: "Check", error: "No images selected"))
            return
        }
        
        currentSessionUUID = UUID().uuidString
        let tempDir = getResTempDirectory()
        
        // Step 2: Convert
        DispatchQueue.main.async {
            self.state.accept(.converting(progress: 0, current: 0, total: items.count))
        }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            var convertedFiles: [URL] = []
            var errors: [String] = []
            
            for (index, item) in items.enumerated() {
                DispatchQueue.main.async {
                    self.state.accept(.converting(progress: Float(index) / Float(items.count), current: index + 1, total: items.count))
                }
                
                let opt = JLBmpConvertOption()
                opt.convertType = self.mode
                opt.pixelformat = self.packageType
                opt.packetFormat = self.packetFormat
                
                let outFilename = (item.filename as NSString).deletingPathExtension + ".res"
                let outPath = tempDir.appendingPathComponent(outFilename)
                
                let result = JLBmpConvert.convert(opt, inFilePath: item.url.path, outFilePath: outPath.path)
                
                if result.result > 0 {
                    convertedFiles.append(outPath)
                } else {
                    errors.append("\(item.filename): convert failed")
                }
            }
            
            if convertedFiles.isEmpty {
                DispatchQueue.main.async {
                    self.state.accept(.failed(step: "Convert", error: "All conversions failed: \n" + errors.joined(separator: "\n")))
                }
                return
            }
            
            // Step 3: Package
            DispatchQueue.main.async {
                self.state.accept(.packing)
            }
            
            var packageInfos: [JLPackageBaseInfo] = []
            for fileUrl in convertedFiles {
                let info = JLPackageBaseInfo()
                info.fileName = fileUrl.lastPathComponent
                info.contentData = try! Data(contentsOf: fileUrl)
                packageInfos.append(info)
            }
            
            let packageData = JLPackageSourceMgr.makePks(packageInfos)
            
            let timestamp = Int(Date().timeIntervalSince1970)
            let packageUrl = self.getPackagesDirectory().appendingPathComponent("\(timestamp).package")
            
            do {
                try packageData.write(to: packageUrl)
                DispatchQueue.main.async {
                    self.packageFileUrl.accept(packageUrl)
                    self.startTransfer(packageUrl: packageUrl)
                }
            } catch {
                DispatchQueue.main.async {
                    self.state.accept(.failed(step: "Package", error: "Failed to write package file: \(error.localizedDescription)"))
                }
            }
        }
    }
    
    func retryTransfer() {
        if let url = packageFileUrl.value {
            startTransfer(packageUrl: url)
        } else {
            state.accept(.failed(step: "Retry", error: "No package file found to retry"))
        }
    }
    
    private func startTransfer(packageUrl: URL) {
        guard (BleManager.shared.currentCmdMgr != nil) else {
            state.accept(.failed(step: "Transfer", error: "Device is disconnected"))
            return
        }
        
        guard let dialMgr = dialMgr else {
            state.accept(.failed(step: "Transfer", error: "Dial Manager not initialized"))
            return
        }
        
        guard let data = try? Data(contentsOf: packageUrl) else {
            state.accept(.failed(step: "Transfer", error: "Failed to read package data"))
            return
        }
        
        state.accept(.transferring(progress: 0))
        
        let namePath = "/" + targetFileName
        dialMgr.updateFile(toDevice: .FLASH, data: data, filePath: namePath) { [weak self] status, progress, err in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if let err = err {
                    self.state.accept(.failed(step: "Transfer", error: err.localizedDescription))
                    return
                }
                
                if status == 0 {
                    self.state.accept(.success(message: "Transfer completed successfully!"))
                } else if status == 1 {
                    self.state.accept(.transferring(progress: Float(progress)))
                } else {
                    self.state.accept(.failed(step: "Transfer", error: "Status code: \(status)"))
                }
            }
        }
    }
    
    // MARK: - Cache Management
    
    func getResTempDirectory() -> URL {
        let cachesDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let tempDir = cachesDir.appendingPathComponent("res_temp").appendingPathComponent(currentSessionUUID)
        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        return tempDir
    }
    
    func getPackagesDirectory() -> URL {
        let cachesDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let pkgDir = cachesDir.appendingPathComponent("packages")
        try? FileManager.default.createDirectory(at: pkgDir, withIntermediateDirectories: true)
        return pkgDir
    }
    
    func clearCaches() {
        let cachesDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let tempDir = cachesDir.appendingPathComponent("res_temp")
        let pkgDir = cachesDir.appendingPathComponent("packages")
        
        try? FileManager.default.removeItem(at: tempDir)
        try? FileManager.default.removeItem(at: pkgDir)
        
        packageFileUrl.accept(nil)
        selectedImages.accept([])
        state.accept(.idle)
    }
}
