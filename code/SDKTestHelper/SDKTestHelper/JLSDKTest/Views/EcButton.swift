//
//  EcButton.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2025/6/9.
//  Copyright © 2025 www.zh-jieli.com. All rights reserved.
//

import UIKit

class EcButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        stepUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init() {
        super.init(frame: .zero)
        stepUI()
    }
    
    private func stepUI() {
        self.backgroundColor = .random()
        self.setTitleColor(.white, for: .normal)
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true
    }
}
