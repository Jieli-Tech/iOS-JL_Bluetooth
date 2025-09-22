//
//  FuncCodeShowCell.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2025/3/11.
//  Copyright © 2025 www.zh-jieli.com. All rights reserved.
//

import UIKit
import WebKit

class FuncCodeMode {
    var title = ""
    var detail = ""
    var code = ""
}

class FuncCodeShowCell: UITableViewCell {
    private let codeText = CodeView()
    private let mainLabView = UIView()
    private let titleLab = UILabel()
    private let detailLab = UILabel()
    private let showBtn = UIButton()
    private var switchStatus: Bool = false
    private let disposeBag = DisposeBag()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        bindAction()
    }

    private func setupUI() {
        contentView.addSubview(codeText)
        contentView.addSubview(mainLabView)
        mainLabView.addSubview(titleLab)
        mainLabView.addSubview(detailLab)
        mainLabView.addSubview(showBtn)

        mainLabView.backgroundColor = .white

        titleLab.font = .systemFont(ofSize: 14, weight: .semibold)
        titleLab.textColor = .darkText
        titleLab.adjustsFontSizeToFitWidth = true

        detailLab.textColor = .lightText
        detailLab.font = .systemFont(ofSize: 12)
        detailLab.adjustsFontSizeToFitWidth = true

        showBtn.setImage(.iconCodeClose, for: .normal)

        codeText.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview().inset(6)
            make.height.equalTo(0)
        }
        mainLabView.snp.makeConstraints { make in
            make.top.equalTo(codeText.snp.bottom)
            make.left.right.equalToSuperview().inset(6)
            make.bottom.equalToSuperview()
        }

        titleLab.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(detailLab.snp.height)
            make.bottom.equalTo(detailLab.snp.top)
            make.right.equalTo(showBtn.snp.left).offset(-6)
        }
        detailLab.snp.makeConstraints { make in
            make.left.bottom.equalToSuperview()
            make.top.equalTo(titleLab.snp.bottom)
            make.right.equalTo(showBtn.snp.left).offset(-6)
            make.height.equalTo(titleLab.snp.height)
        }
        showBtn.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.width.height.equalTo(30)
            make.right.equalToSuperview()
            make.top.bottom.equalToSuperview().inset(10)
        }
    }

    private func bindAction() {
        showBtn.rx.tap.subscribe(onNext: { [weak self] in
            guard let self = self, let tableView = self.superview as? UITableView else { return }
            self.switchStatus.toggle()
            UIView.animate(withDuration: 0.3) {
                self.codeText.snp.updateConstraints { make in
                    make.height.equalTo(self.switchStatus ? self.codeText.webHeight : 0)
                }
                tableView.beginUpdates()
                tableView.endUpdates()
                self.layoutIfNeeded()
            }
            showBtn.setImage(switchStatus ? .iconCodeOpen : .iconCodeClose, for: .normal)
        }).disposed(by: disposeBag)
    }

    func bind(model: FuncCodeMode) {
        titleLab.text = model.title
        detailLab.text = model.detail
        codeText.setCode(code: model.code)
        codeText.onHeightUpdated = { [weak self] in
            guard let self = self else { return }
            self.updateHeight()
        }
        if detailLab.text == "" {
            titleLab.snp.remakeConstraints { make in
                make.left.equalToSuperview()
                make.right.equalTo(showBtn.snp.left).offset(-6)
                make.centerY.equalToSuperview()
            }
            detailLab.snp.remakeConstraints { make in
                make.left.bottom.equalToSuperview()
                make.top.equalTo(titleLab.snp.bottom)
                make.right.equalTo(showBtn.snp.left).offset(-6)
            }
        } else {
            titleLab.snp.remakeConstraints { make in
                make.left.equalToSuperview()
                make.top.equalToSuperview()
                make.height.equalTo(detailLab.snp.height)
                make.bottom.equalTo(detailLab.snp.top)
                make.right.equalTo(showBtn.snp.left).offset(-6)
            }
            detailLab.snp.remakeConstraints { make in
                make.left.bottom.equalToSuperview()
                make.top.equalTo(titleLab.snp.bottom)
                make.right.equalTo(showBtn.snp.left).offset(-6)
                make.height.equalTo(titleLab.snp.height)
            }
        }
    }

    private func updateHeight() {
        guard let tableView = superview as? UITableView else { return }

        tableView.beginUpdates()
        tableView.endUpdates()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class CodeView: BaseView, WKNavigationDelegate {
    private let webView = WKWebView()
    var webHeight: CGFloat = 0
    var onHeightUpdated: (() -> Void)?
    private var copyBtn = UIButton()
    private var currentCode: String?

    override func initUI() {
        super.initUI()
        webView.navigationDelegate = self
        webView.scrollView.isScrollEnabled = false
        addSubview(copyBtn)
        copyBtn.setTitle("Copy code", for: .normal)
        copyBtn.setTitleColor(.white, for: .normal)
        copyBtn.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        copyBtn.backgroundColor = .random()
        copyBtn.layer.cornerRadius = 10
        copyBtn.layer.masksToBounds = true
        addSubview(webView)
        copyBtn.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalToSuperview().inset(8)
            make.height.lessThanOrEqualTo(40)
        }
        webView.snp.makeConstraints { make in
            make.top.equalTo(copyBtn.snp.bottom).offset(8)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }

    override func initData() {
        copyBtn.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            UIPasteboard.general.string = currentCode
            AppDelegate.getCurrentWindows()?.makeToast("Copy Success", position: .center)
        }).disposed(by: disposeBag)
    }

    func setCode(code: String) {
        let htmlString = """
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.5.1/styles/github.min.css">
            <script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.5.1/highlight.min.js"></script>
            <style>
                body {
                    margin: 0;
                    padding: 0;
                    background-color: #1e1e1e; /* 深色背景 */
                    color: white;
                    font-size: 16px;
                    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
                }
                pre {
                    margin: 10px;
                    padding: 12px;
                    border-radius: 8px; /* 圆角 */
                    background: #282c34; /* 代码块背景 */
                    color: #abb2bf; /* 代码颜色 */
                    font-family: "Menlo", "Monaco", "Courier New", monospace;
                    font-size: 14px;
                    line-height: 1.6;
                    white-space: pre; /* 代码不换行 */
                    overflow-x: auto; /* 允许横向滚动 */
                    box-shadow: 0 4px 8px rgba(0, 0, 0, 0.3); /* 阴影 */
                }
                code {
                    font-size: inherit;
                    color: inherit;
                }
            </style>
        </head>
        <body>
        <pre><code class="language-javascript">\(code)</code></pre>
        <script>hljs.highlightAll();</script>
        </body>
        </html>
        """
        currentCode = code
        webView.loadHTMLString(htmlString, baseURL: nil)
    }

    func webView(_ webView: WKWebView, didFinish _: WKNavigation!) {
        webView.evaluateJavaScript("document.body.scrollHeight") { [weak self] height, error in
            guard let self = self, let height = height as? CGFloat, error == nil else { return }
            if self.webHeight != height {
                self.webHeight = height + 40
                self.onHeightUpdated?() // 通知 cell 重新计算高度
            }
        }
    }
}
