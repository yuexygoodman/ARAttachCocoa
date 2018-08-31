//
//  AttachControl.swift
//  ARDemo
//
//  Created by Good Man on 2018/8/13.
//  Copyright © 2018年 Good Man. All rights reserved.
//

import Foundation
import SceneKit

public typealias EventHandler = (AttachControl,Event)->Void

open class AttachControl:SCNNode {
    private var handlers:[Event:[EventHandler]]=[:]
    public func add(handler:@escaping EventHandler ,for event:Event) -> Void {
        if let _ = handlers[event] {
            handlers[event]!.append(handler)
        }
        else{
            handlers[event]=[handler]
        }
    }
    public func removeHandlers(for event:Event) -> Void {
        handlers[event]=nil
    }
    @discardableResult
    open func respond(to event:Event) -> Bool {
        for key in self.handlers.keys {
            if key == event {
                var ev = key
                ev.state = event.state
                let hds = self.handlers[key]!
                if var sound = ev.sound {
                    sound.play()
                    ev.sound = sound
                }
                if var feature = ev.feature {
                    feature.flash(self)
                    ev.feature=feature
                }
                if ev.state.shouldTrigger {
                    for handler in hds {
                        handler(self,event)
                    }
                }
                self.handlers[ev]=hds
                return true
            }
        }
        return false
    }
}
