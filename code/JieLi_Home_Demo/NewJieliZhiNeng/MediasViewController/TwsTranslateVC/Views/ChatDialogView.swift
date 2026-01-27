//
//  ChatDialogView.swift
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2025/5/22.
//  Copyright © 2025 杰理科技. All rights reserved.
//

import UIKit

class ChatMessageInfo {
    var title: String
    var titleColor: UIColor
    var original: String
    var originalColor: UIColor = .eHex("#000000", alpha: 0.9)
    var translate: String
    var translateColor: UIColor
    var startTime: Double
    let uid: UUID
    var info: CallRecord?
    var faceInfo: FaceToFaceRecord?
    init(startTime: Double, title: String, titleColor: UIColor, original: String, translate: String, translateColor: UIColor, uid: UUID = UUID()) {
        self.startTime = startTime
        self.title = title
        self.titleColor = titleColor
        self.original = original
        self.translate = translate
        self.translateColor = translateColor
        self.uid = uid
    }
}

class ChatDialogView: BasicView {
    private let tableView: UITableView = {
        let tv = UITableView()
        tv.register(TranslateSpeakView.self, forCellReuseIdentifier: "TranslateSpeakView")
        tv.separatorStyle = .none
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = 60
        tv.keyboardDismissMode = .interactive
        tv.backgroundColor = .clear
        return tv
    }()

    
    let messages = BehaviorRelay<[ChatMessageInfo]>(value: [])
    var tableBag: Disposable?
    var didSelect: ((ChatMessageInfo) -> Void)?
    private var messageList: [ChatMessageInfo] = []

    override func initUI() {
        super.initUI()
        backgroundColor = .clear
        addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    override func initData() {
        super.initData()
        messages.bind(to: tableView.rx.items(cellIdentifier: "TranslateSpeakView", cellType: TranslateSpeakView.self)) { _, model, cell in
            cell.selectionStyle = .none // 取消点击高亮效果，但仍保留点击事件
            cell.configTitle(title: model.title, color: model.titleColor)
            cell.configContent(original: model.original, originalColor: model.originalColor, translate: model.translate, translateColor: model.translateColor)
        }.disposed(by: disposeBag)
        
        tableView.rx.modelSelected(ChatMessageInfo.self).subscribe(onNext: { [weak self] model in
            guard let self = self else { return }
            self.didSelect?(model)
            tableView.reloadData()
        }).disposed(by: disposeBag)
        
        // 新消息插入后自动滚到底部
        tableBag = messages
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let tv = self?.tableView else { return }
                let count = tv.numberOfRows(inSection: 0)
                if count > 0 {
                    let index = IndexPath(row: count - 1, section: 0)
                    tv.scrollToRow(at: index, at: .bottom, animated: true)
                }
            })
    }

    // MARK: - 单个 Cell 刷新

    /// 更新指定索引的消息并刷新对应 cell
    func updateMessage(at index: Int, with newInfo: ChatMessageInfo, animation: UITableView.RowAnimation = .none) {
        guard index >= 0, index < messageList.count else { return }
        // 更新本地数组并发射新值
        messageList[index] = newInfo
        messages.accept(messageList)
        // 刷新对应的 cell
        let indexPath = IndexPath(row: index, section: 0)
        tableView.reloadRows(at: [indexPath], with: animation)
    }

    func scrollToIndex(_ index: Int) {
        guard index >= 0, index < messages.value.count else { return }
        let indexPath = IndexPath(row: index, section: 0)
        if let visibleRows = tableView.indexPathsForVisibleRows, let lastVisible = visibleRows.last, indexPath.row > lastVisible.row {
            return
        }
        tableView.scrollToRow(at: indexPath, at: .top, animated: true)
    }

    deinit {
        tableBag?.dispose()
    }
}

// MARK: - 测试数据

extension ChatDialogView {
    /// 返回一组测试用的对话数据
    static func sampleMessages() -> [ChatMessageInfo] {
        return [
            ChatMessageInfo(
                startTime: 0,
                title: "13345067894 (我)",
                titleColor: .systemGreen,
                original: "Hello, my spoken language is not very good, so a translator will be communicating with you on my behalf. Please excuse me.",
                translate: "你好，我的口语不好，会由翻译代我与你沟通，请见谅。",
                translateColor: .eHex("#000000", alpha: 0.5)
            ),
            ChatMessageInfo(
                startTime:10,
                title: "对方",
                titleColor: .systemRed,
                original: "Hello, 请开始你的表演。",
                translate: "Hello. Please start your performance.",
                translateColor: .eHex("#000000", alpha: 0.5)
            ),
            ChatMessageInfo(
                startTime: 20,
                title: "13345067894 (我)",
                titleColor: .systemGreen,
                original: "OK.",
                translate: "好的。",
                translateColor: .eHex("#000000", alpha: 0.5)
            ),
            ChatMessageInfo(
                startTime: 30,
                title: "对方",
                titleColor: .systemRed,
                original: "所以说。开始说话了吗?",
                translate: "So say. Have you started talking?",
                translateColor: .eHex("#000000", alpha: 0.5)
            ),
            ChatMessageInfo(
                startTime: 40,
                title: "13345067894 (我)",
                titleColor: .systemGreen,
                original: "What are you doing? Yes. I am talking now.",
                translate: "你在干什么。是的。我现在正在说话。",
                translateColor: .eHex("#000000", alpha: 0.5)
            ),
            ChatMessageInfo(
                startTime: 50,
                title: "对方",
                titleColor: .systemRed,
                original: "Could you please describe your background briefly?",
                translate: "你能简要介绍一下你的背景吗？",
                translateColor: .eHex("#000000", alpha: 0.5)
            ),
            ChatMessageInfo(
                startTime: 60,
                title: "13345067894 (我)",
                titleColor: .systemGreen,
                original: "Sure! I have been working in software development for over 5 years, specializing in mobile apps.",
                translate: "当然！我从事软件开发已有5年多，专注于移动应用。",
                translateColor: .eHex("#000000", alpha: 0.5)
            ),
            ChatMessageInfo(
                startTime: 65,
                title: "对方",
                titleColor: .systemRed,
                original: "That's impressive. What tech stack do you prefer?",
                translate: "这很令人印象深刻。你更喜欢哪种技术栈？",
                translateColor: .eHex("#000000", alpha: 0.5)
            ),
            ChatMessageInfo(
                startTime: 70,
                title: "13345067894 (我)",
                titleColor: .systemGreen,
                original: "I usually use Swift for iOS, Kotlin for Android, and Node.js for backend services.",
                translate: "我通常在iOS上使用Swift，在Android上使用Kotlin，后端使用Node.js。",
                translateColor: .eHex("#000000", alpha: 0.5)
            ),
            ChatMessageInfo(
                startTime: 80,
                title: "对方",
                titleColor: .systemRed,
                original: "Sounds good. Let's move on to the next topic.",
                translate: "听起来不错。我们进入下一个话题吧。",
                translateColor: .eHex("#448EFF")
            ),
        ]
    }

    /// 返回一组测试用的对话数据（手机端与耳机端对话）
    static func sampleFaceToFaceMessages() -> [ChatMessageInfo] {
        return [
            ChatMessageInfo(
                startTime: 0,
                title: "手机端",
                titleColor: .systemBlue,
                original: "正在尝试连接耳机...",
                translate: "Trying to connect to earphones...",
                translateColor: .eHex("#000000", alpha: 0.5)
            ),
            ChatMessageInfo(
                startTime: 10,
                title: "耳机端",
                titleColor: .systemOrange,
                original: "Connection established successfully.",
                translate: "连接已成功建立",
                translateColor: .eHex("#000000", alpha: 0.5)
            ),
            ChatMessageInfo(
                startTime: 20,
                title: "手机端",
                titleColor: .systemBlue,
                original: "当前电量剩余85%，需要开启省电模式吗？",
                translate: "Battery level at 85%, enable power saving mode?",
                translateColor: .eHex("#000000", alpha: 0.5)
            ),
            ChatMessageInfo(
                startTime: 30,
                title: "耳机端",
                titleColor: .systemOrange,
                original: "Negative. Battery level sufficient for 6 hours operation.",
                translate: "不需要。电量足够支持6小时运行。",
                translateColor: .eHex("#000000", alpha: 0.5)
            ),
            ChatMessageInfo(
                startTime: 40,
                title: "手机端",
                titleColor: .systemBlue,
                original: "检测到新固件版本2.1.3，是否立即更新？",
                translate: "New firmware version 2.1.3 detected, update now?",
                translateColor: .eHex("#000000", alpha: 0.5)
            ),
            ChatMessageInfo(
                startTime: 50,
                title: "耳机端",
                titleColor: .systemOrange,
                original: "建议在充电状态下进行固件更新。当前电量可能不足。",
                translate: "Recommend updating while charging. Current battery may be insufficient.",
                translateColor: .eHex("#000000", alpha: 0.5)
            ),
            ChatMessageInfo(
                startTime:60,
                title: "手机端",
                titleColor: .systemBlue,
                original: "已连接到充电器，开始更新固件...",
                translate: "Connected to charger, starting firmware update...",
                translateColor: .eHex("#000000", alpha: 0.5)
            ),
            ChatMessageInfo(
                startTime: 70,
                title: "耳机端",
                titleColor: .systemOrange,
                original: "Update progress: 25%. Do not disconnect.",
                translate: "更新进度：25%。请勿断开连接。",
                translateColor: .eHex("#000000", alpha: 0.5)
            ),
            ChatMessageInfo(
                startTime:80,
                title: "手机端",
                titleColor: .systemBlue,
                original: "固件更新完成！新功能包括：增强的降噪模式和自定义EQ设置。",
                translate: "Firmware update complete! New features include enhanced noise cancellation and custom EQ settings.",
                translateColor: .eHex("#000000", alpha: 0.5)
            ),
            ChatMessageInfo(
                startTime: 86,
                title: "耳机端",
                titleColor: .systemOrange,
                original: "Update verification successful. All systems operational.",
                translate: "更新验证成功。所有系统运行正常。",
                translateColor: .eHex("#448EFF")
            ),
        ]
    }
}
