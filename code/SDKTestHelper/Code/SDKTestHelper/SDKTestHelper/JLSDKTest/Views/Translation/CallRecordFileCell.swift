//
//  CallRecordFileCell.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2026/6/8.
//  Copyright © 2026 www.zh-jieli.com. All rights reserved.
//

import RxSwift
import SnapKit
import UIKit

class CallRecordFileCell: BaseView {
    
    /// 文件名标签
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .black
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    /// 来源类型标签
    private let sourceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .white
        label.textAlignment = .center
        label.layer.cornerRadius = 4
        label.layer.masksToBounds = true
        return label
    }()
    
    /// 详情标签（大小+时长+时间）
    private let detailLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .gray
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    /// 播放按钮
    let playBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(systemName: "play.fill"), for: .normal)
        btn.setImage(UIImage(systemName: "stop.fill"), for: .selected)
        btn.tintColor = .systemBlue
        return btn
    }()
    
    /// 分享按钮
    let shareBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        btn.tintColor = .systemBlue
        return btn
    }()
    
    /// 删除按钮
    let deleteBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(systemName: "trash"), for: .normal)
        btn.tintColor = .systemRed
        return btn
    }()
    
    override func initUI() {
        super.initUI()
        
        backgroundColor = .white
        layer.cornerRadius = 8
        layer.masksToBounds = true
        
        addSubview(sourceLabel)
        addSubview(nameLabel)
        addSubview(detailLabel)
        addSubview(playBtn)
        addSubview(shareBtn)
        addSubview(deleteBtn)
        
        sourceLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.top.equalToSuperview().offset(10)
            make.width.equalTo(60)
            make.height.equalTo(20)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(sourceLabel.snp.right).offset(8)
            make.right.equalTo(playBtn.snp.left).offset(-8)
            make.centerY.equalTo(sourceLabel)
        }
        
        detailLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.right.equalTo(playBtn.snp.left).offset(-8)
            make.top.equalTo(sourceLabel.snp.bottom).offset(6)
            make.bottom.equalToSuperview().offset(-10)
        }
        
        playBtn.snp.makeConstraints { make in
            make.right.equalTo(shareBtn.snp.left).offset(-8)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(30)
        }
        
        shareBtn.snp.makeConstraints { make in
            make.right.equalTo(deleteBtn.snp.left).offset(-8)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(30)
        }
        
        deleteBtn.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(30)
        }
    }
    
    /// 配置单元格数据
    func configure(with file: CallRecordFile, isPlaying: Bool) {
        nameLabel.text = file.name
        detailLabel.text = "\(file.sourceType.displayName) | \(file.sizeString) | \(file.durationString) | \(file.createDateString)"
        playBtn.isSelected = isPlaying
        
        switch file.sourceType {
        case .up:
            sourceLabel.backgroundColor = .systemBlue
            sourceLabel.text = "上行"
        case .down:
            sourceLabel.backgroundColor = .systemOrange
            sourceLabel.text = "下行"
        case .stereo:
            sourceLabel.backgroundColor = .systemPurple
            sourceLabel.text = "立体声"
        case .simultaneousMaster:
            sourceLabel.backgroundColor = .systemGreen
            sourceLabel.text = "主机"
        case .simultaneousSlave:
            sourceLabel.backgroundColor = .systemTeal
            sourceLabel.text = "从机"
        }
    }
}
