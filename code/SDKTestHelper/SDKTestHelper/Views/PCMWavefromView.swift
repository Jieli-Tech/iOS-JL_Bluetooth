//
//  PCMWavefromView.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2025/5/13.
//  Copyright © 2025 www.zh-jieli.com. All rights reserved.
//
import UIKit

class PCMWaveformView: UIView {

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

    var waveformColor: UIColor = .eHex("#F38450") {
        didSet { setNeedsDisplay() }
    }

    // 控制一帧抽取多少采样点
    var samplesPerFrame: Int = 1

    // 控制最多保留多少个样本点（防止 UI 堆积过多）
    var maxVisibleSamples: Int = 100

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .white
    }

    override func draw(_ rect: CGRect) {
        guard !samples.isEmpty else { return }
        guard let context = UIGraphicsGetCurrentContext() else { return }

        context.clear(rect)
        UIColor.white.setFill()
        context.fill(rect)
        
        let midY = bounds.midY
        let stepX = barWidth + barSpacing
        let totalWidth = CGFloat(samples.count) * stepX
        let startX = max(bounds.width - totalWidth, 0)

        for (i, sample) in samples.enumerated() {
            let x = startX + CGFloat(i) * stepX
            let height = CGFloat(sample) * bounds.height / 2
            let y = midY - height
            let barRect = CGRect(x: x, y: y, width: barWidth, height: height * 2)
            let roundedBar = UIBezierPath(roundedRect: barRect, cornerRadius: barCornerRadius)
            waveformColor.setFill()
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
            return pcm.map { abs(Float($0)) / Float(Int16.max) }
        }

        let step = Double(pcm.count) / Double(targetCount)
        var result: [Float] = []

        for i in 0..<targetCount {
            let index = Int(Double(i) * step)
            let sample = pcm[index]
            result.append(abs(Float(sample)) / Float(Int16.max))
        }
        return result
    }

    func reset() {
        samples.removeAll()
        setNeedsDisplay()
    }
}
