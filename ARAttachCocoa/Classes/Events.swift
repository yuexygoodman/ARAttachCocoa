//
//  Events.swift
//  ARDemo
//
//  Created by Good Man on 2018/8/17.
//  Copyright © 2018年 Good Man. All rights reserved.
//

import Foundation

public enum EventStatus {
    case possible
    case begin
    case inprogress(Int)
    case end
    case invalid
}

public typealias EventData = Any

public struct Event:Hashable {
    public var hashValue: Int{
        return name.rawValue.hashValue
    }
    public static func == (lhs: Event, rhs: Event) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    public let name:Event.Name
    public internal(set) var sound:Sound?
    public internal(set) var feature:Feature?
    public var state:(status:EventStatus,data:EventData?,shouldTrigger:Bool)=(.possible,nil,false)
    public init(name:Event.Name,sound:Sound?=nil,feature:Feature?=nil) {
        self.name=name
        self.sound=sound
        self.feature=feature
    }
}

extension Event {
    public struct Name:Hashable,RawRepresentable {
        public var hashValue: Int{
            return rawValue.hashValue
        }
        public static func == (lhs: Name, rhs: Name) -> Bool {
            return lhs.hashValue == rhs.hashValue
        }
        public init(rawValue: String) {
            self.rawValue=rawValue
        }
        public let rawValue: RawValue
        public typealias RawValue = String
    }
}

//touch
extension Event.Name {
    public static let touch = Event.Name.init(rawValue: "Touch")
}
extension Event {
    public static let touch = Event.init(name: Event.Name.touch)
    public static func touch(_ sound:Sound?,_ feature:Feature?)->Event {
        return Event.init(name: Event.Name.touch, sound: sound,feature: feature)
    }
}

//click
extension Event.Name {
    public static let click = Event.Name.init(rawValue: "Click")
}
extension Event {
    public static let click = Event.init(name: Event.Name.click)
    public static func click(_ sound:Sound?,_ feature:Feature?) -> Event {
        return Event.init(name: Event.Name.click, sound: sound, feature: feature)
    }
}


