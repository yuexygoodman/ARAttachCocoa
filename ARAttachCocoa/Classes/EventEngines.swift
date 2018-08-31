//
//  EventEngine.swift
//  ARDemo
//
//  Created by Good Man on 2018/8/20.
//  Copyright © 2018年 Good Man. All rights reserved.
//

import Foundation
import SceneKit

public protocol EventEngine {
    var event:Event {get set}
    func run() -> Void
    func stop() -> Void
    init(with view:AttachSceneView)
}

class EventEngines {
    static func engine(with name:Event.Name,view:AttachSceneView) -> EventEngine? {
        var bundles = [Bundle.main,Bundle.init(for:self)]
        bundles.append(contentsOf: Bundle.allFrameworks)
        bundles.append(contentsOf: Bundle.allBundles)
        for bundle in bundles {
            guard let infoDic = bundle.infoDictionary,
                let namespace = infoDic["CFBundleExecutable"] as? String else {
                continue
            }
            let className = "\(namespace).\(name.rawValue)Engine"
            let anyClass:AnyObject.Type? = NSClassFromString(className)
            if let engineClass = anyClass as? EventEngine.Type {
                return engineClass.init(with: view)
            }
        }
        return nil
    }
}


class TouchEngine:EventEngine {
    var event: Event = .touch
    unowned let view:AttachSceneView
    var tap:UITapGestureRecognizer?
    required init(with view: AttachSceneView) {
        self.view=view
    }
    func run() {
        let touch = UITapGestureRecognizer.init(target: self, action: #selector(self.tap(tap:)))
        touch.numberOfTouchesRequired=1
        view.addGestureRecognizer(touch)
        self.tap = touch
    }
    func stop() {
        if let tap = self.tap {
            self.view.removeGestureRecognizer(tap)
        }
    }
    @objc func tap(tap:UITapGestureRecognizer) -> Void {
        let point = tap.location(in: self.view)
        self.event.state = (.end,nil,true)
        let results=self.view.hitTest(point, options: nil)
        var node = results.first?.node
        while node != nil {
            guard let control = node as? AttachControl,control.respond(to: event) else {
                node=node?.parent
                continue
            }
            break
        }
    }
}

extension AttachSceneView {
    override open func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let _ = self.enabledEvents, self.enabledEvents!.contains(.click),(self.events[.click] as! ClickEngine).control != nil {
            return false
        }
        return true
    }
    func gesturesEnabled(b:Bool) -> Void {
        if let gestures = self.gestureRecognizers {
            for gesture in gestures {
                gesture.isEnabled=b
            }
        }
    }
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let _ = self.enabledEvents, self.enabledEvents!.contains(.click) {
            let point=touches.first!.location(in: self)
            let results=self.hitTest(point, options: nil)
            var node = results.first?.node
            let engine = self.events[.click] as! ClickEngine
            engine.reset()
            while node != nil {
                var click:Event = .click
                click.state = (.begin,nil,false)
                guard let control = node as? AttachControl,control.respond(to: click) else {
                    node=node?.parent
                    continue
                }
                engine.control=control
                engine.event.state = (.begin,nil,false)
                self.gesturesEnabled(b: false)
                return
            }
        }
        super.touchesBegan(touches, with: event)
    }
    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let _ = self.enabledEvents, self.enabledEvents!.contains(.click) {
            let engine = self.events[.click] as! ClickEngine
            if case (.invalid,_,_) = engine.event.state {
                return
            }
            let point=touches.first!.location(in: self)
            let results=self.hitTest(point, options: nil)
            var node = results.first?.node
            while node != nil {
                guard node! === engine.control else {
                    node = node?.parent
                    continue
                }
                return
            }
            if engine.control != nil {
                engine.event.state = (.invalid,nil,false)
                engine.control?.respond(to: engine.event)
                return
            }
        }
        super.touchesMoved(touches, with: event)
    }
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.gesturesEnabled(b: true)
        if let _ = self.enabledEvents, self.enabledEvents!.contains(.click) {
            let point=touches.first!.location(in: self)
            let results=self.hitTest(point, options: nil)
            var node = results.first?.node
            let engine = self.events[.click] as! ClickEngine
            while node != nil {
                guard node! === engine.control else {
                    node = node?.parent
                    continue
                }
                engine.event.state = (.end,nil,true)
                engine.control?.respond(to: engine.event)
                return
            }
        }
        super.touchesEnded(touches, with: event)
    }
    override open func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.gesturesEnabled(b: true)
        if let _ = self.enabledEvents, self.enabledEvents!.contains(.click) {
            let point=touches.first!.location(in: self)
            let results=self.hitTest(point, options: nil)
            var node = results.first?.node
            let engine = self.events[.click] as! ClickEngine
            while node != nil {
                guard node! === engine.control else {
                    node = node?.parent
                    continue
                }
                engine.event.state = (.end,nil,true)
                engine.control?.respond(to: engine.event)
                return
            }
        }
        super.touchesCancelled(touches, with: event)
    }
}

class ClickEngine:EventEngine {
    var event: Event = .click
    unowned let view:AttachSceneView
    fileprivate weak var control:AttachControl?
    required init(with view: AttachSceneView) {
        self.view = view
    }
    func run() {
        
    }
    func stop() {
        
    }
    func reset() -> Void {
        self.event.state = (.possible,nil,false)
        self.control = nil
    }
}
