//
//  CallTranslateSideModel.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2026/8/19.
//  Copyright © 2026 www.zh-jieli.com. All rights reserved.
//

import Foundation
import JL_BLEKit

/// 通话翻译「一侧」（己方 / 对方）的 UI 数据模型
///
/// 把 `VolcesBusManager` 暴露的文本流与统计流适配成详情页可消费的 BehaviorRelay，
/// 并固化角色、语言方向与统计口径，避免详情页直接触碰底层 manager。
final class CallTranslateSideModel {

    let roleText: String
    let sourceLanguage: TranslateLanguage
    let targetLanguage: TranslateLanguage

    // MARK: - 文本流

    let originStreamingText = BehaviorRelay<String>(value: "")
    let definiteOriginText = BehaviorRelay<String>(value: "")
    let definiteTranslatedText = BehaviorRelay<String>(value: "")
    let currentTtsText = BehaviorRelay<String>(value: "")

    // MARK: - 统计流

    let statsInputBytes = BehaviorRelay<Int>(value: 0)
    let statsInputPackets = BehaviorRelay<Int>(value: 0)
    let statsOutputBytes = BehaviorRelay<Int>(value: 0)
    let statsOutputPackets = BehaviorRelay<Int>(value: 0)
    let statsTtsOutputBytes = BehaviorRelay<Int>(value: 0)
    let statsOriginTextBytes = BehaviorRelay<Int>(value: 0)
    let statsTranslatedTextBytes = BehaviorRelay<Int>(value: 0)

    private var disposeBag = DisposeBag()

    init(roleText: String,
         sourceLanguage: TranslateLanguage,
         targetLanguage: TranslateLanguage,
         manager: VolcesBusManager) {
        self.roleText = roleText
        self.sourceLanguage = sourceLanguage
        self.targetLanguage = targetLanguage
        bind(to: manager)
    }

    private func bind(to manager: VolcesBusManager) {
        // 文本流
        manager.subtitleText
            .filter { !$0.isEmpty }
            .distinctUntilChanged()
            .bind(to: originStreamingText)
            .disposed(by: disposeBag)

        manager.definiteTextOrigin
            .filter { !$0.isEmpty }
            .distinctUntilChanged()
            .bind(to: definiteOriginText)
            .disposed(by: disposeBag)

        manager.definiteTextTranslate
            .filter { !$0.isEmpty }
            .distinctUntilChanged()
            .bind(to: definiteTranslatedText)
            .disposed(by: disposeBag)

        manager.targetPcmData
            .map { $0.1.joined(separator: " | ") }
            .filter { !$0.isEmpty }
            .distinctUntilChanged()
            .bind(to: currentTtsText)
            .disposed(by: disposeBag)

        // 输入统计（manager 已在 startTranslateData / startTranslatePcmData 中累加）
        manager.statsInputBytes
            .bind(to: statsInputBytes)
            .disposed(by: disposeBag)

        manager.statsInputPackets
            .bind(to: statsInputPackets)
            .disposed(by: disposeBag)

        // 输出音频统计
        manager.targetData
            .filter { !$0.isEmpty }
            .subscribe(onNext: { [weak self] data in
                guard let self = self else { return }
                self.statsOutputBytes.accept(self.statsOutputBytes.value + data.count)
                self.statsOutputPackets.accept(self.statsOutputPackets.value + 1)
            })
            .disposed(by: disposeBag)

        // TTS 输出统计
        manager.targetPcmData
            .map { $0.0.count }
            .filter { $0 > 0 }
            .subscribe(onNext: { [weak self] count in
                guard let self = self else { return }
                self.statsTtsOutputBytes.accept(self.statsTtsOutputBytes.value + count)
            })
            .disposed(by: disposeBag)

        // 原文 / 译文文本统计
        manager.definiteTextOrigin
            .filter { !$0.isEmpty }
            .subscribe(onNext: { [weak self] text in
                guard let self = self else { return }
                self.statsOriginTextBytes.accept(self.statsOriginTextBytes.value + text.utf8.count)
            })
            .disposed(by: disposeBag)

        manager.definiteTextTranslate
            .filter { !$0.isEmpty }
            .subscribe(onNext: { [weak self] text in
                guard let self = self else { return }
                self.statsTranslatedTextBytes.accept(self.statsTranslatedTextBytes.value + text.utf8.count)
            })
            .disposed(by: disposeBag)
    }

    /// 解除与 manager 的绑定
    func dispose() {
        disposeBag = DisposeBag()
    }
}
