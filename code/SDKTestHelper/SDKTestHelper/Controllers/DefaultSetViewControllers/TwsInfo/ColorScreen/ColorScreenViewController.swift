//
//  ColorScreenViewController.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2025/4/1.
//  Copyright © 2025 www.zh-jieli.com. All rights reserved.
//

import UIKit

class ColorScreenViewController: BaseViewController {
    
    let colorScreenVM:ColorScreenVM = ColorScreenVM()
    private let funcList: BehaviorRelay<[String]> = BehaviorRelay(value: [])
    private let getScreenSaverBtn = UIButton()
    private let getWallPaperBtn = UIButton()
    private let currentWallPaperLab = UILabel()
    private let currentScreenSaverLab = UILabel()
    private let wallPaperTableView = UITableView()
    private let screenSaverTableView = UITableView()
    private let progressView = UIProgressView()
    private let funcLab = UILabel()
    private let funcTableView = UITableView()
    
    lazy var fotaHUD: UIAlertController = {
        let alert = UIAlertController(title: "Updating File to Device\n", message: nil, preferredStyle: .alert)
        let indicator = UIActivityIndicatorView(frame: alert.view.bounds)
        indicator.style = .large
        indicator.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        alert.view.addSubview(indicator)
        indicator.isUserInteractionEnabled = false
        indicator.startAnimating()
        return alert
    }()
    
    
    
    override func initUI() {
        super.initUI()
        navigationView.title = "Color Screen Box"
        navigationView.leftBtn.setTitle(R.localStr.back(), for: .normal)
        getScreenSaverBtn.setTitle("Get Screen Saver/WallPaper ", for: .normal)
        getScreenSaverBtn.setTitleColor(.white, for: .normal)
        getScreenSaverBtn.backgroundColor = UIColor.random()
        getScreenSaverBtn.layer.cornerRadius = 10
        getScreenSaverBtn.layer.masksToBounds = true
        getScreenSaverBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        view.addSubview(getScreenSaverBtn)
        
        currentScreenSaverLab.text = "Current Screen Saver:"
        currentScreenSaverLab.textColor = .black
        currentScreenSaverLab.font = .boldSystemFont(ofSize: 12)
        currentScreenSaverLab.adjustsFontSizeToFitWidth = true
        currentScreenSaverLab.textAlignment = .center
        view.addSubview(currentScreenSaverLab)
        
        screenSaverTableView.rowHeight = 40
        screenSaverTableView.register(UITableViewCell.self, forCellReuseIdentifier: "ScreenSaverCell")
        colorScreenVM.screenSaverList.bind(to: screenSaverTableView.rx.items(cellIdentifier: "ScreenSaverCell", cellType: UITableViewCell.self)) { index, model, cell in
            cell.textLabel?.text = model.fileName
            cell.textLabel?.textColor = .black
            cell.backgroundColor = .white
        }.disposed(by: disposeBag)
        view.addSubview(screenSaverTableView)
        
        currentWallPaperLab.text = "Current WallPaper:"
        currentWallPaperLab.textColor = .black
        currentWallPaperLab.font = .boldSystemFont(ofSize: 12)
        currentWallPaperLab.adjustsFontSizeToFitWidth = true
        currentWallPaperLab.textAlignment = .center
        view.addSubview(currentWallPaperLab)
        
        wallPaperTableView.rowHeight = 40
        wallPaperTableView.register(UITableViewCell.self, forCellReuseIdentifier: "WallPaperCell")
        colorScreenVM.wallPaperList.bind(to: wallPaperTableView.rx.items(cellIdentifier: "WallPaperCell",cellType: UITableViewCell.self)) { index, model, cell in
            cell.textLabel?.text = model.fileName
            cell.textLabel?.textColor = .black
            cell.backgroundColor = .white
        }.disposed(by: disposeBag)
        view.addSubview(wallPaperTableView)
        
        progressView.progress = 0
        view.addSubview(progressView)
        
        funcLab.text = "Function"
        funcLab.textColor = .black
        view.addSubview(funcLab)
        
        funcTableView.rowHeight = 40
        funcTableView.register(UITableViewCell.self, forCellReuseIdentifier: "FuncCell")
        funcList.bind(to: funcTableView.rx.items(cellIdentifier: "FuncCell",cellType: UITableViewCell.self)) { index, model, cell in
            cell.textLabel?.text = model
            cell.textLabel?.textColor = .black
            cell.backgroundColor = .white
        }.disposed(by: disposeBag)
        view.addSubview(funcTableView)
        
        
        
        getScreenSaverBtn.snp.makeConstraints { make in
            make.top.equalTo(navigationView.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(40)
        }
        
        currentScreenSaverLab.snp.makeConstraints { make in
            make.top.equalTo(getScreenSaverBtn.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(16)
        }
        
        screenSaverTableView.snp.makeConstraints { make in
            make.top.equalTo(currentScreenSaverLab.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(100)
        }
        
        currentWallPaperLab.snp.makeConstraints { make in
            make.top.equalTo(screenSaverTableView.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(16)
        }
        
        wallPaperTableView.snp.makeConstraints { make in
            make.top.equalTo(currentWallPaperLab.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(100)
        }
        
        progressView.snp.makeConstraints { make in
            make.top.equalTo(wallPaperTableView.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(16)
        }
        
        funcLab.snp.makeConstraints { make in
            make.top.equalTo(progressView.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(16)
        }
        
        funcTableView.snp.makeConstraints { make in
            make.top.equalTo(funcLab.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(100)
        }

    }
    override func initData() {
        super.initData()
        funcList.accept(["Transport Screen Saver VIE1", "Transport Screen Saver VIE2", "Transport WallPaper CSBG_001", "Transport WallPaper CSBG_002"])
        
        navigationView.leftBtn.rx.tap.subscribe { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }.disposed(by: disposeBag)
        
        getScreenSaverBtn.rx.tap.subscribe { [weak self] _ in
            self?.colorScreenVM.getScreenSaverListAndWallPaper()
        }.disposed(by: disposeBag)
        
        colorScreenVM.currentScreensaverModel.subscribe(onNext: { [weak self] model in
            self?.currentScreenSaverLab.text = "Current Screen Saver: " + model.filePath
        }).disposed(by: disposeBag)
        
        colorScreenVM.currentWallPaperModel.subscribe(onNext: { [weak self] model in
            self?.currentWallPaperLab.text = "Current WallPaper: " + model.filePath
        }).disposed(by: disposeBag)
        
        funcTableView.rx.itemSelected.subscribe(onNext: { [weak self] index in
            guard let self = self else { return }
            switch index.row {
            case 0:
                guard let filePath = R.file.vie1Png(),
                      let data = try? Data(contentsOf: filePath) else { return }
                colorScreenVM.addScreenSaver(data) { state, progress, err in
                    self.displayState(state, Float(progress))
                }
                break
            case 1:
                break
            case 2:
                guard let filePath = R.file.csbg_001Png(),
                      let data = try? Data(contentsOf: filePath) else { return }
                colorScreenVM.addWallPaper(data) { state, progress, err in
                    self.displayState(state, Float(progress))
                }
                break
            case 3:
                break
            default:
                break
            }
        }).disposed(by: disposeBag)
        
        wallPaperTableView.rx.modelSelected(JLDialSourceModel.self).subscribe(onNext: { [weak self] model in
            self?.colorScreenVM.setWallPaper(model)
        }).disposed(by: disposeBag)
        
        wallPaperTableView.rx.modelDeleted(JLDialSourceModel.self).subscribe(onNext: {[weak self] model in
            self?.colorScreenVM.deleteScreenSaverOrWallPaper(model)
        }).disposed(by: disposeBag)
        
    }
    
    private func displayState(_ state:Bool , _ progress:Float) {
        progressView.progress = progress
    }
    
    
    
    

}
