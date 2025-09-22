//
//  Tools.swift
//  JLAudioUnitKitDemo
//
//  Created by EzioChan on 2024/11/26.
//

import UIKit

class Tools: NSObject {
    
    static let speexPath = basePath + "/speexDecode"
    static let opusPath = basePath + "/opusDecode"
    static let opusEncodePath = basePath + "/opusEncode"
    static let wtgPath = basePath + "/wtgEncode"
    static let wavPath = basePath + "/wav"

    
    
    static private let basePath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
    
    static func createFolders(){
      
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: speexPath) {
            try? fileManager.createDirectory(atPath: speexPath, withIntermediateDirectories: true, attributes: nil)
        }
        if !fileManager.fileExists(atPath: opusPath) {
            try? fileManager.createDirectory(atPath: opusPath, withIntermediateDirectories: true, attributes: nil)
        }
        if !fileManager.fileExists(atPath: opusEncodePath) {
            try? fileManager.createDirectory(atPath: opusEncodePath, withIntermediateDirectories: true, attributes: nil)
        }
        if !fileManager.fileExists(atPath: wtgPath) {
            try? fileManager.createDirectory(atPath: wtgPath, withIntermediateDirectories: true, attributes: nil)
        }
        
        if !fileManager.fileExists(atPath: wavPath) {
            try? fileManager.createDirectory(atPath: wavPath, withIntermediateDirectories: true, attributes: nil)
        }
        
    }
    

}
