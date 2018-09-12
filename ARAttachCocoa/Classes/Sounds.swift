//
//  Sounds.swift
//  ARDemo
//
//  Created by Good Man on 2018/8/13.
//  Copyright © 2018年 Good Man. All rights reserved.
//

import Foundation
import AVFoundation

public struct Sound:FragmentCombination {
    typealias FragmentType = Sound
    var index: Int=0
    var fragments: [Sound]=[]
    
    public internal(set) var systemId:SystemSoundID?=nil
    internal var url:URL?
    internal var player:AVPlayer?
    init() {
    }
    public init(_ systemId:SystemSoundID) {
        self.systemId=systemId
    }
    public init(_ mediaUrl:URL) {
        var soundId:SystemSoundID=0
        AudioServicesCreateSystemSoundID(mediaUrl as CFURL, &soundId)
        self.systemId = soundId
        self.url = mediaUrl
    }
    public mutating func play() -> Void {
        if self.systemId != nil {
            AudioServicesPlaySystemSound(self.systemId!)
        }
        else {
            if var sound = self.next() {
                sound.play()
            }
        }
    }
    public mutating func playback() -> Void {
        if let url = self.url {
            self.player = self.player ?? AVPlayer.init(url: url)
            self.player?.play()
        }
    }
}

//dang
extension Sound {
    public static let dang = Sound.init(URL.init(fileURLWithPath:Bundle.attach.path(forResource: "dang", ofType: "wav")!))
}

//bo
extension Sound {
    public static let bo = Sound.init(URL.init(fileURLWithPath:Bundle.attach.path(forResource: "bo", ofType: "mp3")!))
}

//tita
extension Sound {
    fileprivate static let ti = Sound.init(URL.init(fileURLWithPath: Bundle.attach.path(forResource: "ti", ofType: "wav")!))
    fileprivate static let ta = Sound.init(URL.init(fileURLWithPath: Bundle.attach.path(forResource: "ta", ofType: "wav")!))
    public static let tita:Sound = [.ti,.ta]
}
