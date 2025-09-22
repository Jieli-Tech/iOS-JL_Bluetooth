//
//  DhaDataFitting.swift
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2022/7/6.
//  Copyright © 2022 杰理科技. All rights reserved.
//

import Foundation
import JL_BLEKit





@objcMembers public class DhaHandlerModel:NSObject{
    var freqList:[String] = []
    var maxIndex:Int = 0
    var shouldTag:Int = 0
    var barValues:[NSNumber] = []
    var meanValue:Float = 0.0
}





@objcMembers public class FittingMgr:NSObject{
    
    public var dhaList:[DhaFittingData] = []

    var fittingIndex = 0
    
    public override init() {
        super.init()
    }
    
    @objc public init(info:DhaFittingInfo,channel:DhaChannel) {
        super.init()
        for item in info.ch_freq {
            let v = item as! NSNumber
            let fit = DhaFittingData()
            fit.channel = channel
            if channel == .left {
                fit.leftOn = true
                fit.rightOn = false
            }else{
                fit.leftOn = false
                fit.rightOn = true
            }
            fit.gain = 0.0
            fit.freq = UInt16(v.intValue)
            dhaList.append(fit)
        }
    }
    
    func nextModel()->Bool{
        if fittingIndex+1 < dhaList.count {
            fittingIndex+=1
            return true
        }else{
            return false
        }
    }
    
    func previousModel()->Bool{
        if fittingIndex-1 >= 0 {
            fittingIndex-=1
            return true
        }else{
            return false
        }
    }
    
    func getNowModel()->DhaFittingData{
        dhaList[fittingIndex]
    }
    
    func checkoutNowList()->DhaHandlerModel{
        let model = DhaHandlerModel()
        model.shouldTag = fittingIndex
        var barsValue:[NSNumber] = []
        var freqList:[String] = []
        var mean:Float = 0.0
        for item in dhaList {
            let num = NSNumber(value: item.gain)
            mean+=item.gain
            barsValue.append(num)
            if item.freq/1000 > 0 {
                freqList.append(String(format:"%dK", Int(item.freq)/1000))
            }else{
                freqList.append(String(format:"%d", item.freq))
            }
        }
        
        model.maxIndex = dhaList.count
        model.freqList = freqList
        model.barValues = barsValue
        model.meanValue = mean/Float(freqList.count)
        return model
    }
  
    
    
}

extension Double{
    func isSame(_ value:Double)->Bool{
        let v = String(format: "%.3f", self)
        let v2 = String(format: "%.3f", value)
        return  v2 == v
    }
}

@objcMembers public class FittingResult:NSObject{
    var gain:Float = 0.0
    var isFinish:Bool = false
    
    @discardableResult func reset(_ g:Float,_ finish:Bool)->Self{
        self.gain = g
        self.isFinish = finish
        return self
    }
}


@objcMembers public class FittingCheck:NSObject{
    var gain:Float = 50.0
    var aLower:Float = 50.0
    var aUpper:Float = 50.0
    var count = 0
    var intNumber = 0
    var upperOrLower = 0
    var result = FittingResult()
    
    static let share = FittingCheck()
    
    
    public override init() {
        super.init()
        
    }
    
    func reset(){
        gain = 50.0
        aLower = 50.0
        aUpper = 50.0
        count = 0
        intNumber = 0
        upperOrLower = 0
    }
    
    
    func change(st:Bool)->FittingResult{
        print("\(intNumber)")
        if intNumber == 0{
            //第一次执行
            intNumber+=1
            if st {
                aLower-=10
                upperOrLower = 0
                return result.reset(aLower,false)
            }else{
                aUpper+=10
                upperOrLower = 1
                return result.reset(aUpper,false)
            }
        }
        
        if intNumber == 1 {
            //第一次听得见的情况
            if upperOrLower == 0  {
                if st {
                    aUpper = aLower
                    if aUpper == 0 {
                        //finish
                        print("finish")
                        gain = 0.0
                        return result.reset(0.0,true)
                    }
                    aLower-=10
                    return result.reset(aLower,false)
                }else{
                    gain = (aUpper+aLower)/2
                    intNumber+=1
                    return result.reset(gain,false)
                    
                }
            }
            
            if upperOrLower == 1 {
                if st {
                    gain = (aUpper+aLower)/2
                    intNumber+=1
                    return  result.reset(gain,false)
                    
                }else{
                    aLower = aUpper
                    if aLower == 100 {
                        print("finish")
                        gain = 100.0
                        return result.reset(100.0,true)
                        
                    }
                    aUpper+=10
                    return result.reset(aUpper,false)
                    
                }
            }
            
        }
        
        if intNumber == 2 {
            if upperOrLower == 0  {
                if st {
                    aUpper = gain
                    count+=1
                    if count == 2 {
                        //finish
                        print("finish")
                        return result.reset(gain,true)
                    }
                    gain = (aUpper+aLower)/2
                    return result.reset(gain,false)
                    
                }else{
                    aLower = gain
                    count = 0
                    if abs(gain-aUpper) > 0.25{
                        //finish
                        print("finish")
                        return result.reset(gain,true)
                    }
                    gain = (aUpper+aLower)/2
                    return result.reset(gain,false)
                }
            }
            
            if upperOrLower == 1 {
                if st {
                    aUpper = gain
                    count = 0
                    if abs(gain-aLower) > 0.25{
                        print("finish")
                        return result.reset(gain,true)
                    }
                    gain = (aUpper+aLower)/2
                    return result.reset(gain,false)
                }else{
                    aLower = gain
                    count+=1
                    if count == 2 {
                        print("finish")
                        return result.reset(gain,true)
                    }
                    gain = (aUpper+aLower)/2
                    return result.reset(gain,false)
                }
            }
            
        }
        return result.reset(-1.0,true)
    }
}
