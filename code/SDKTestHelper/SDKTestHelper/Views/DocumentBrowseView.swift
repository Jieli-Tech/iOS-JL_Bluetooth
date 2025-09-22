//
//  DocumentBrowseView.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2025/5/14.
//  Copyright © 2025 www.zh-jieli.com. All rights reserved.
//

import UIKit
import RxSwift
import SnapKit

class DocumentBrowserView: BaseView, UITableViewDelegate, UITableViewDataSource {
    private let tableView = UITableView()
    private var currentPath: String = ""
    private var contents: [String] = []
    private var pathStack: [String] = []

    private var initialPath: String?

    // UI: 简易导航栏
    private let navBar = UIView()
    private let backButton = UIButton(type: .system)
    private let titleLabel = UILabel()

    public init(initialPath: String?) {
        self.initialPath = initialPath
        super.init()
    }

    override func initUI() {
        // 添加导航栏
        addSubview(navBar)
        navBar.addSubview(backButton)
        navBar.addSubview(titleLabel)

        navBar.backgroundColor = .systemGray6
        navBar.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(44)
        }

        backButton.setTitle(R.localStr.back(), for: .normal)
        backButton.setTitleColor(.black, for: .normal)
        backButton.backgroundColor = .clear
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        backButton.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(12)
            make.centerY.equalToSuperview()
            make.width.equalTo(50)
        }

        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .darkText
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.left.greaterThanOrEqualTo(backButton.snp.right).offset(10)
        }

        // 添加 tableView
        addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.snp.makeConstraints { make in
            make.top.equalTo(navBar.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    override func initData() {
        let startPath = initialPath ?? FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.path ?? ""
        loadDirectory(at: startPath, isPush: false)
    }

    private func loadDirectory(at path: String, isPush: Bool = true) {
        currentPath = path
        if isPush {
            pathStack.append(path)
        } else {
            pathStack = [path]
        }

        do {
            contents = try FileManager.default.contentsOfDirectory(atPath: path)
        } catch {
            contents = []
        }

        titleLabel.text = path.replacingOccurrences(of: NSHomeDirectory(), with: "~") // 更短的路径显示
        backButton.isHidden = pathStack.count <= 1

        tableView.reloadData()
    }

    // MARK: - UITableView

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contents.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let name = contents[indexPath.row]
        let fullPath = (currentPath as NSString).appendingPathComponent(name)
        var isDir: ObjCBool = false
        FileManager.default.fileExists(atPath: fullPath, isDirectory: &isDir)

        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        // 设置图标和文本
        let icon = isDir.boolValue ? R.image.folder() : R.image.file()
        cell.imageView?.image = icon
        cell.imageView?.contentMode = .scaleAspectFit
        cell.textLabel?.text = name

        cell.accessoryType = isDir.boolValue ? .disclosureIndicator : .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let name = contents[indexPath.row]
        let fullPath = (currentPath as NSString).appendingPathComponent(name)
        var isDir: ObjCBool = false
        FileManager.default.fileExists(atPath: fullPath, isDirectory: &isDir)

        tableView.deselectRow(at: indexPath, animated: true)

        if isDir.boolValue {
            loadDirectory(at: fullPath)
        } else {
            shareFile(at: fullPath)
        }
    }

    private func shareFile(at path: String) {
        let url = URL(fileURLWithPath: path)
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        contextView?.present(activityVC, animated: true)
    }

    // MARK: - 返回上一层目录
    @objc public func backTapped() {
        guard pathStack.count > 1 else { return }
        pathStack.removeLast()
        let previous = pathStack.last!
        loadDirectory(at: previous, isPush: false)
    }

    public func goBack() {
        backTapped()
    }
}
