//
//  UpdateSrcViewController.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2025/3/21.
//  Copyright © 2025 www.zh-jieli.com. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class UpdateSrcViewController: BaseViewController {
    let selectFileBtn = UIButton()
    let initializeBtn = UIButton()
    let startOtaBtn = UIButton()
    let fileLab = UILabel()
    let statusLab = UILabel()
    let progressView = UIProgressView()
    let fileListView = FileLoadView()
    let updateVM = UpdateSrcVM()
    
    override func viewWillAppear(_: Bool) {
        super.viewWillAppear(true)
        BaseViewController.listenDisconnect(false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        BaseViewController.listenDisconnect(true)
    }
    
    override func initUI() {
        super.initUI()
        navigationView.title = "Update Src"
        navigationView.leftBtn.setTitle(R.localStr.back(), for: .normal)
        // Add subviews
        view.addSubview(selectFileBtn)
        view.addSubview(initializeBtn)
        view.addSubview(startOtaBtn)
        view.addSubview(fileLab)
        view.addSubview(statusLab)
        view.addSubview(progressView)
        view.addSubview(fileListView)
        
        // Configure UI elements
        configureUI()
        
        // Set up constraints using SnapKit
        setupConstraints()
        
        // Bind button actions with RxSwift
        bindActions()
    }
    
    private func configureUI() {
        // Configure buttons
        selectFileBtn.setTitle("Select File", for: .normal)
        selectFileBtn.setTitleColor(.white, for: .normal)
        selectFileBtn.backgroundColor = .random()
        selectFileBtn.layer.cornerRadius = 8
        selectFileBtn.layer.masksToBounds = true
        
        initializeBtn.setTitle("Initialize", for: .normal)
        initializeBtn.setTitleColor(.white, for: .normal)
        initializeBtn.backgroundColor = .random()
        initializeBtn.layer.cornerRadius = 8
        initializeBtn.layer.masksToBounds = true
        
        startOtaBtn.setTitle("Start OTA", for: .normal)
        startOtaBtn.setTitleColor(.white, for: .normal)
        startOtaBtn.backgroundColor = .random()
        startOtaBtn.layer.cornerRadius = 8
        startOtaBtn.layer.masksToBounds = true
        startOtaBtn.isEnabled = false
        
        // Configure labels
        fileLab.text = "Selected File: None"
        fileLab.textColor = .black
        fileLab.textAlignment = .center
        
        statusLab.text = "Status: Idle"
        statusLab.textColor = .black
        statusLab.textAlignment = .center
        
        // Configure progress view
        progressView.progress = 0.0
        progressView.progressTintColor = .systemBlue
        progressView.trackTintColor = .lightGray
        
        fileListView.isHidden = true
    }
    
    private func setupConstraints() {
        selectFileBtn.snp.makeConstraints { make in
            make.top.equalTo(navigationView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
        
        fileLab.snp.makeConstraints { make in
            make.top.equalTo(selectFileBtn.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(30)
        }
        
        initializeBtn.snp.makeConstraints { make in
            make.top.equalTo(fileLab.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
        
        startOtaBtn.snp.makeConstraints { make in
            make.top.equalTo(initializeBtn.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
        
        statusLab.snp.makeConstraints { make in
            make.top.equalTo(startOtaBtn.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(30)
        }
        
        progressView.snp.makeConstraints { make in
            make.top.equalTo(statusLab.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(4)
        }
        
        fileListView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(navigationView.snp.bottom)
        }
    }
    
    private func bindActions() {
        
        navigationView.leftBtn.rx.tap.subscribe { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }.disposed(by: disposeBag)
        
        // Select File Button Action
        selectFileBtn.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.fileListView.isHidden = false
                self?.fileListView.showFiles(_R.path.srcs)
            })
            .disposed(by: disposeBag)
        
        fileListView.handleBlock = { [weak self] file in
            self?.fileLab.text = (file as NSString).lastPathComponent
            self?.updateVM.srcFilePath = file
        }
        
        // Initialize Button Action
        initializeBtn.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.statusLab.text = "Status: Initializing"
                self.updateVM.srcSystemInit() { status in
                    self.statusLab.text = "Status: \(status ? "Initialized" : "Failed to Initialize")"
                    self.startOtaBtn.isEnabled = status
                }
            })
            .disposed(by: disposeBag)
        
        // Start OTA Button Action
        startOtaBtn.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.statusLab.text = "Status: OTA Started"
                self?.updateVM.startOta()
            })
            .disposed(by: disposeBag)
        
        updateVM.progressPresent.subscribe { [weak self] progress in
            DispatchQueue.main.async {
                self?.progressView.progress = Float(progress)
            }
        }.disposed(by: disposeBag)
            
        
        updateVM.stateStr.subscribe { [weak self] state in
            DispatchQueue.main.async {
                self?.statusLab.text = "Status: " + state
            }
        }.disposed(by: disposeBag)
    }
}
