//
//  AttachSceneView.swift
//  ARDemo
//
//  Created by Good Man on 2018/7/30.
//  Copyright © 2018年 Good Man. All rights reserved.
//

import UIKit
import ARKit

open class AttachSceneView: ARSCNView {
    fileprivate var gestures:[UIGestureRecognizer]=[]
    var events:[Event.Name:EventEngine]=[:]
    public var controls:ControlOptions? {
        didSet {
            for gesture in  gestures {
                self.removeGestureRecognizer(gesture)
            }
            gestures.removeAll()
            guard let _ = controls else {
                return
            }
            if controls!.contains(.Scale) {
                let pinch = UIPinchGestureRecognizer.init(target: self, action: #selector(self.scale(pinch:)))
                self.addGestureRecognizer(pinch)
                gestures.append(pinch)
            }
            if controls!.contains(.Translate) {
                let pan = UIPanGestureRecognizer.init(target: self, action: #selector(self.translate(pan:)))
                pan.minimumNumberOfTouches=1
                pan.maximumNumberOfTouches=1
                self.addGestureRecognizer(pan)
                gestures.append(pan)
            }
            if controls!.contains(.Rotate) {
                let pan = UIPanGestureRecognizer.init(target: self, action: #selector(self.rotate(pan:)))
                pan.minimumNumberOfTouches=2
                self.addGestureRecognizer(pan)
                gestures.append(pan)
            }
            if controls!.contains(.Relocate) {
                let tap = UITapGestureRecognizer.init(target: self, action: #selector(self.relocate(tap:)))
                tap.numberOfTapsRequired = 2
                self.addGestureRecognizer(tap)
                gestures.append(tap)
            }
        }
    }
    fileprivate var transforms:[SCNNode:SCNMatrix4]=[:]
    public var enabledEvents:[Event.Name]? {
        didSet {
            for engine in self.events.values {
                engine.stop()
            }
            self.events = [:]
            guard let newEvents = enabledEvents else {
                return
            }
            for event in newEvents {
                if let engine = EventEngines.engine(with: event, view: self) {
                    engine.run()
                    self.events[event]=engine
                }
            }
        }
    }
}

public struct ControlOptions: OptionSet {
    public let rawValue: Int8
    public init(rawValue:Int8) {
        self.rawValue = rawValue
    }
    public static let Scale = ControlOptions(rawValue: 1 << 0)
    public static let Translate = ControlOptions(rawValue: 1 << 1)
    public static let Rotate = ControlOptions(rawValue: 1 << 2)
    public static let Relocate = ControlOptions(rawValue: 1 << 3)
    
    public static let all: ControlOptions = [.Scale, .Translate,.Rotate, .Relocate]
}

extension AttachSceneView {
    fileprivate func cacheOldTranforms() -> Void {
        for node in self.scene.rootNode.childNodes {
            if !transforms.keys.contains(node) {
                transforms[node]=node.transform
            }
        }
    }
    @objc fileprivate func scale(pinch:UIPinchGestureRecognizer) -> Void {
        self.cacheOldTranforms()
        guard let frame = self.session.currentFrame else {
            return
        }
        let position = SCNVector3.init(frame.camera.transform.columns.3.x,frame.camera.transform.columns.3.y, frame.camera.transform.columns.3.z)
        let distance = (pinch.scale-1)*0.1
        for node in self.scene.rootNode.childNodes {
            let vector = SCNVector3.init(position.x-node.position.x, position.y-node.position.y, position.z-node.position.z)
            let len = sqrt(vector.x*vector.x+vector.y*vector.y+vector.z*vector.z)
            let scale = (Float)(distance)/len
            node.position = SCNVector3.init(node.position.x+vector.x*scale, node.position.y+vector.y*scale, node.position.z+vector.z*scale)
        }
        pinch.scale=1
    }
    
    @objc fileprivate func translate(pan:UIPanGestureRecognizer) -> Void {
        self.cacheOldTranforms()
        let point = pan.velocity(in: self)
        for node in self.scene.rootNode.childNodes {
            guard node.camera == nil else {
                continue
            }
            node.position = SCNVector3.init(node.position.x+Float(point.x*0.00001), node.position.y+Float(-point.y*0.00001), node.position.z)
        }
    }
    
    @objc fileprivate func rotate(pan:UIPanGestureRecognizer) -> Void {
        self.cacheOldTranforms()
        let point = pan.velocity(in: self)
        func stike (node:SCNNode) {
            guard !(node is AttachControl) else {
                node.eulerAngles.z = node.eulerAngles.z-Float(point.x*0.0001)
                node.eulerAngles.x = node.eulerAngles.x+Float(point.y*0.0001)
                return
            }
            for child in node.childNodes {
                stike(node: child)
            }
        }
        stike(node: self.scene.rootNode)
    }
    
    @objc fileprivate func relocate(tap:UITapGestureRecognizer) -> Void {
        for node in self.scene.rootNode.childNodes {
            if let transform = transforms[node] {
                node.transform = transform
            }
        }
    }
}

