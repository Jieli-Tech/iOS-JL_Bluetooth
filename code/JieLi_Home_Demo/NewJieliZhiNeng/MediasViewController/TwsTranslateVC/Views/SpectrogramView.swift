//
//  SpectrogramView.swift
//  JLAudioUnitKitDemo
//
//  Created by EzioChan on 2024/11/27.
//

import Accelerate
import UIKit

class SpectrogramView: BasicView {
    private var samples: [Float] = []

    // MARK: - 样式属性（可外部设置）

    var barWidth: CGFloat = 2 {
        didSet { setNeedsDisplay() }
    }

    var barSpacing: CGFloat = 2 {
        didSet { setNeedsDisplay() }
    }

    var barCornerRadius: CGFloat = 1 {
        didSet { setNeedsDisplay() }
    }

    var barColor: UIColor = .eHex("#F38450") {
        didSet { setNeedsDisplay() }
    }

    // 为顶部和底部保留的间距，避免波纹条贴边
    var verticalPadding: CGFloat = 2 {
        didSet { setNeedsDisplay() }
    }

    // 最小可见高度（保证中间刻度不至于太短）
    var minBarHeight: CGFloat = 2 {
        didSet { setNeedsDisplay() }
    }

    // 振幅增益（>1 放大，<1 压缩）
    var amplitudeGain: CGFloat = 1.2 {
        didSet { setNeedsDisplay() }
    }

    // 振幅曲线：true 使用开方（提升中间可见度），false 线性
    var useSqrtCurve: Bool = true {
        didSet { setNeedsDisplay() }
    }

    // 控制一帧抽取多少采样点
    var samplesPerFrame: Int = 1

    // 控制最多保留多少个样本点（防止 UI 堆积过多）
    var maxVisibleSamples: Int = 100

    var currentBgColor: UIColor = .eHex("#F3F4F6")

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }

        // 背景
        context.clear(rect)
        currentBgColor.setFill()
        context.fill(rect)

        // 没有样本时不绘制波纹条
        guard !samples.isEmpty else { return }

        let midY = bounds.midY
        let stepX = barWidth + barSpacing
        let totalWidth = CGFloat(samples.count) * stepX
        let startX = max(bounds.width - totalWidth, 0)

        // 预留上下间距后的可用高度
        let availableHeight = max(bounds.height - verticalPadding * 2, 0)

        for (i, sample) in samples.enumerated() {
            let x = startX + CGFloat(i) * stepX

            // 将原始采样归一化到 [0,1]
            var normalized = max(0, min(CGFloat(sample) / 2.0, 1))
            // 应用曲线增强：sqrt 提升中低振幅的可见度
            if useSqrtCurve { normalized = sqrt(normalized) }
            // 增益
            normalized = min(normalized * amplitudeGain, 1)

            // 保证最小可见高度，并不超过可用高度
            let baseline = min(minBarHeight, availableHeight)
            let barHeight = baseline + normalized * max(availableHeight - baseline, 0)

            // 以中线为中心绘制
            let y = midY - barHeight / 2
            let barRect = CGRect(x: x, y: y, width: barWidth, height: barHeight)
            let roundedBar = UIBezierPath(roundedRect: barRect, cornerRadius: min(barCornerRadius, barWidth / 2))
            barColor.setFill()
            roundedBar.fill()
        }
    }

    // MARK: - PCM 接口（Data 类型，Int16 单声道）

    func appendPCMData(from pcmData: Data) {
        let count = pcmData.count / MemoryLayout<Int16>.size
        guard count > 0 else { return }

        let pcmArray = pcmData.withUnsafeBytes { ptr -> [Int16] in
            let buffer = ptr.bindMemory(to: Int16.self)
            return Array(buffer.prefix(count))
        }

        let frameSamples = extractFrameSamples(pcmArray, targetCount: samplesPerFrame)
        samples.append(contentsOf: frameSamples)

        if samples.count > maxVisibleSamples {
            samples.removeFirst(samples.count - maxVisibleSamples)
        }

        setNeedsDisplay()
    }

    // MARK: - 提取样本

    private func extractFrameSamples(_ pcm: [Int16], targetCount: Int) -> [Float] {
        guard pcm.count >= targetCount else {
            return pcm.map { abs(Float($0)) / Float(Int16.max) * 2 }
        }

        let step = Double(pcm.count) / Double(targetCount)
        var result: [Float] = []

        for i in 0 ..< targetCount {
            let index = Int(Double(i) * step)
            let sample = pcm[index]
            result.append(abs(Float(sample)) / Float(Int16.max) * 2)
        }
        return result
    }

    func reset() {
        samples.removeAll()
        setNeedsDisplay()
    }
}
