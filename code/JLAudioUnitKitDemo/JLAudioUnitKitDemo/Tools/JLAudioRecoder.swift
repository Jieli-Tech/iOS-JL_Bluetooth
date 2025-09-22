//
//  JLAudioRecoder.swift
//  JLAudioUnitKitDemo
//
//  Created by EzioChan on 2024/11/26.
//

import UIKit
import AVFoundation

class JLAudioRecoder: NSObject, AVAudioRecorderDelegate {
    private var audioRecoder:AVAudioRecorder?
    private var recodingSession:AVAudioSession!
    
    static let shared = JLAudioRecoder()
    
    override init() {
        super.init()
        recodingSession = AVAudioSession.sharedInstance()
        do {
            try recodingSession.setCategory(.playAndRecord, mode: .default)
            try recodingSession.setActive(true)
            recodingSession.requestRecordPermission {  allowed in
                if allowed {
                    print("Mic permission granted")
                }else{
                    print("Mic permission not granted")
                }
            }
        } catch {
            print("Failed to set audio session category",error)
        }
        
       
    }
    
    func start(_ path:String,_ sampleRate:Double = 16000.0,_ bitRate:Int = 16,_ channel:Int = 1) {
        let settings:[String : Any] = [AVFormatIDKey: kAudioFormatLinearPCM,
                            AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue,
                                 AVEncoderBitRateKey: bitRate,
                               AVNumberOfChannelsKey: channel,
                                     AVSampleRateKey: sampleRate]
        do {
            audioRecoder = try AVAudioRecorder(url: URL(fileURLWithPath: path), settings: settings)
            audioRecoder?.delegate = self
            audioRecoder?.record()
        } catch {
            print("Failed to create audio recoder",error)
        }
    }
    
    func stop() {
        audioRecoder?.stop()
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            print("Audio recoder finished")
        }
    }
    
}


