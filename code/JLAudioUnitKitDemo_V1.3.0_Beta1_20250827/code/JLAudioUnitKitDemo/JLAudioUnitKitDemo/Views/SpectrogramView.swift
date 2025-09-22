//
//  SpectrogramView.swift
//  JLAudioUnitKitDemo
//
//  Created by EzioChan on 2024/11/27.
//

import UIKit
import Accelerate

class SpectrogramView: BaseView {
    
    var pcmData: [Float] = []  // 经过转换后的 PCM 数据
    
    // 设定柱状图的样式
    var barWidth: CGFloat = 2.5  // 每个柱子的宽度
    var barSpacing: CGFloat = 0.5 // 柱子之间的间距
    var barColor: UIColor = UIColor.random() // 柱子的颜色
    
    override func initUI() {
        super.initUI()
        backgroundColor = .white
    }
    
    // 传入 PCM 数据并重新绘制
    func setPcmData(_ data: Data) {
        self.pcmData = self.convertToFloatArray(from: data)
        self.setNeedsDisplay()  // 触发重绘
    }
    
    // 将原始的 PCM 数据（Data）转换为 Float 数组
    private func convertToFloatArray(from data: Data) -> [Float] {
        var result: [Float] = []
        
        // 假设 PCM 数据是 16 位（2 字节）每个样本
        let sampleCount = data.count / 2  // 每个样本2字节
        
        for i in 0..<sampleCount {
//            let byteRange = NSRange(location: i * 2, length: 2)
            let sampleData = data.subdata(in: i * 2 ..< i * 2 + 2)//data.subdata(with: byteRange)
            var sample: Int16 = 0
            (sampleData as NSData).getBytes(&sample, length: 2)
            
            // 将 Int16 数据映射到 -1.0 到 1.0 的范围
            let floatSample = Float(sample) / Float(Int16.max)
            result.append(floatSample)
        }
        
        return result
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard !pcmData.isEmpty else { return }
        
        // 获取绘图上下文
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        // 设置绘图属性
        context.setLineWidth(barWidth)
        context.setStrokeColor(barColor.cgColor)
        
        // 计算柱子的宽度
        let widthPerSample = barWidth + barSpacing
        
        // 绘制柱状图
        for (index, sample) in pcmData.enumerated() {
            // 计算每个柱子的x坐标
            let x = CGFloat(index) * widthPerSample
            
            // 根据振幅计算柱子的y坐标
            // 使用 abs() 取绝对值来避免负值导致的绘制偏低
            let amplitude = CGFloat(abs(sample))  // PCM 数据是[-1.0, 1.0]范围内的浮动值
            
            // 按比例映射振幅到视图高度，确保柱子的高度在整个视图的范围内
            let height = amplitude * rect.height  // 振幅越大，柱子越长
            
            // 将柱子从底部绘制（原点为视图的底部）
            let y = rect.height - height
            
            // 绘制矩形柱子
            context.addRect(CGRect(x: x, y: y, width: barWidth, height: height))
        }
        
        // 填充矩形柱子
        context.setFillColor(barColor.cgColor)
        context.fillPath()
    }

    
}


