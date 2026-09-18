//
//  LogViewController.swift
//  WatchTest
//
//  Created by EzioChan on 2026/6/5.
//  Copyright © 2026 www.zh-jieli.com. All rights reserved.
//

import UIKit

class LogViewController: BaseViewController {
    let textView = UITextView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func initUI() {
        super.initUI()
        navigationView.title = R.localStr.logView()
        navigationView.leftBtn.setTitle(R.localStr.back(), for: .normal)
        navigationView.rightBtn.setTitle(R.localStr.share(), for: .normal)
        navigationView.rightBtn.isHidden = false
        
        textView.font = UIFont.systemFont(ofSize: 12)
        textView.textColor = UIColor.black
        textView.backgroundColor = UIColor.white
        textView.isEditable = false
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        view.addSubview(textView)
        
        textView.snp.makeConstraints { make in
            make.top.equalTo(navigationView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    override func initData() {
        super.initData()
        
        navigationView.leftBtn.rx.tap.subscribe { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }.disposed(by: disposeBag)
        
        navigationView.rightBtn.rx.tap.subscribe { [weak self] _ in
            self?.shareLogFile()
        }.disposed(by: disposeBag)
        
        loadLogContent()
    }
    
    private func loadLogContent() {
        let logPath = logFilePath()
        if let content = try? String(contentsOfFile: logPath, encoding: .utf8) {
            textView.text = content
            // 滚动到末尾
            let range = NSRange(location: content.count - 1, length: 1)
            textView.scrollRangeToVisible(range)
        } else {
            textView.text = "暂无日志内容"
        }
    }
    
    private func logFilePath() -> String {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! + "/JL_Log.txt"
    }
    
    private func shareLogFile() {
        let logPath = logFilePath()
        let fileURL = URL(fileURLWithPath: logPath)
        
        if FileManager.default.fileExists(atPath: logPath) {
            let activityViewController = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = navigationView.rightBtn
            present(activityViewController, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: R.localStr.tips(), message: "日志文件不存在", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: R.localStr.confirm(), style: .default))
            present(alert, animated: true, completion: nil)
        }
    }
}
