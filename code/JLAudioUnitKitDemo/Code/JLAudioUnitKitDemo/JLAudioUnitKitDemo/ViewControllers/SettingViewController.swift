//
//  SettingViewController.swift
//  JLAudioUnitKitDemo
//
//  Created by EzioChan on 2024/11/26.
//

import UIKit
import RxSwift
import RxCocoa

class SettingViewController: BaseViewController {
    private let subTable = UITableView()
    private let itemArray = BehaviorRelay<[(String,String)]>(value: [("PCM Sample Rate","16000"),("PCM Channels","1")])
    
    override func initUI() {
        super.initUI()
        navigationView.title = "Setting"
        view.addSubview(subTable)
        subTable.backgroundColor = .clear
        subTable.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        subTable.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(navigationView.snp.bottom)
        }
    }
    
    override func initData() {
        super.initData()
        itemArray
            .bind(to: subTable.rx.items(cellIdentifier: "cell", cellType: UITableViewCell.self)) { _, item, cell in
                cell.textLabel?.text = item.0
                
                cell.detailTextLabel?.text = item.1
                cell.accessoryType = .disclosureIndicator
            }
            .disposed(by: disposeBag)
        subTable.rx.modelSelected((String,String).self)
            .subscribe(onNext: { [weak self] item in
                guard let self = self else { return }
                if item.0 == "PCM Sample Rate" {
                    self.changeSampleRate(item)
                }
                if item.0 == "PCM Channels" {
                    self.changeChannels(item)
                }
                subTable.reloadData()
            }).disposed(by: disposeBag)
        
    }
    
    private func changeSampleRate(_ model:(String,String)){
        let alert = UIAlertController(title: "Change Sample Rate", message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.text = model.1
            textField.placeholder = "Sample Rate"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            let sampleRate = alert.textFields?.first?.text ?? "16000"
            UserDefaults.standard.set(sampleRate, forKey: "sampleRate")
            self.makeItems()
        }))
        present(alert, animated: true, completion: nil)
    }
    
    private func changeChannels(_ model:(String,String)){
        let alert = UIAlertController(title: "Change Channels", message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.text = model.1
            textField.placeholder = "Channels"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            let channels = alert.textFields?.first?.text ?? "1"
            UserDefaults.standard.set(channels, forKey: "channels")
            self.makeItems()
        }))
        present(alert, animated: true, completion: nil)
    }
    
    private func makeItems(){
        let sampleRate = UserDefaults.standard.string(forKey: "sampleRate") ?? "16000"
        let channels = UserDefaults.standard.string(forKey: "channels") ?? "1"
        itemArray.accept([("PCM Sample Rate",sampleRate),("PCM Channels",channels)])
    }
    
    
}
