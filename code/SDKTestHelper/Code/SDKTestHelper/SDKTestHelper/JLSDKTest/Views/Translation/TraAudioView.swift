//
//  TraAudioView.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2025/6/9.
//  Copyright © 2025 www.zh-jieli.com. All rights reserved.
//

import UIKit

class TraAudioView: BaseView {
    private let textField = UITextView()
    override func initUI() {
        super.initUI()
        stepUI()
    }
    private func stepUI() {
        addSubview(textField)
        textField.isEditable = false
        textField.backgroundColor = .white
        textField.textColor = .darkText
        textField.font = UIFont.systemFont(ofSize: 12)
        textField.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func updateText(_ text: String) {
        textField.text = text
    }

}
