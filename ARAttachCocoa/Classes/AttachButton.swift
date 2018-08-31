//
//  AttachButton.swift
//  ARDemo
//
//  Created by Good Man on 2018/8/13.
//  Copyright © 2018年 Good Man. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

open class AttachButton: AttachControl {
    public fileprivate(set) var textLabel:AttachLabel?
    public var backgroundColor:UIColor=UIColor.white {
        didSet {
            self.setGeometry()
        }
    }
    public var backgroundImage:UIImage? {
        didSet {
            self.setGeometry()
        }
    }
    public var title:String? {
        didSet {
            self.setTextLabel()
        }
    }
    public var size:CGSize=CGSize.zero {
        didSet {
            self.setGeometry()
            self.setTextLabel()
        }
    }
    public var enabled:Bool=true
    convenience public init(with size:CGSize) {
        self.init(with: size, title: nil)
    }
    public init(with size:CGSize,title:String?) {
        super.init()
        self.size=size
        self.title=title
        self.setGeometry()
        self.setTextLabel()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    internal override init() {
        super.init()
    }
    
    open func onclick(_ handler:@escaping EventHandler) -> Void {
        self.removeHandlers(for: .click)
        self.add(handler: handler, for: .click(.tita , .shake))
    }
    fileprivate func setGeometry() -> Void {
        if self.geometry==nil {
            let plane = SCNPlane.init()
            plane.materials.first!.isDoubleSided=true
            self.geometry=plane
        }
        let plane=self.geometry as! SCNPlane
        plane.width=self.size.width
        plane.height=self.size.height
        if self.backgroundImage != nil {
            self.geometry!.materials.first!.diffuse.contents=self.backgroundImage!
        }
        else {
            self.geometry!.materials.first!.diffuse.contents=self.backgroundColor
        }
    }
    fileprivate func setTextLabel() -> Void {
        if let title = self.title {
            if self.textLabel==nil {
                self.textLabel = AttachLabel.init()
                self.addChildNode(self.textLabel!)
            }
            self.textLabel?.size = self.size
            self.textLabel?.string = title
        }
        else{
            self.textLabel?.removeFromParentNode()
            self.textLabel=nil
        }
    }
    open override func respond(to event: Event) -> Bool {
        if !self.enabled {
            return false
        }
        return super.respond(to: event)
    }
}
