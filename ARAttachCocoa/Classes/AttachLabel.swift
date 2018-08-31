//
//  AttachLabel.swift
//  ARDemo
//
//  Created by Good Man on 2018/8/13.
//  Copyright © 2018年 Good Man. All rights reserved.
//

import Foundation
import UIKit
import SceneKit
import CoreFoundation

fileprivate class AttachTextLayer:CATextLayer {
}

open class AttachLabel:AttachControl {
    public var string:Any? {
        didSet {
            self.setTextLayer()
        }
    }
    public var font:CGFont? {
        didSet {
            self.setTextLayer()
        }
    }
    public var fontSize:CGFloat=36 {
        didSet {
            self.setTextLayer()
        }
    }
    public var foregroundColor:UIColor? {
        didSet {
            self.setTextLayer()
        }
    }
    public var isWrapped:Bool=true {
        didSet {
            self.setTextLayer()
        }
    }
    public var truncationMode:String="none" {
        didSet {
            self.setTextLayer()
        }
    }
    public var alignmentMode:String = "natural" {
        didSet {
            self.setTextLayer()
        }
    }
    public var allowsFontSubpixelQuantization:Bool=false {
        didSet {
            self.setTextLayer()
        }
    }
    public var size:CGSize=CGSize.zero {
        didSet {
            self.setGeometry()
            self.setTextLayer()
        }
    }
    fileprivate var textLayer:AttachTextLayer?
    convenience public init(with size:CGSize) {
        self.init(with: size, text: nil)
    }
    public init(with size:CGSize,text:String?) {
        super.init()
        self.size=size
        self.string=text
        self.setGeometry()
        self.setTextLayer()
    }
    public init(with size:CGSize,attributed:NSAttributedString?) {
        super.init()
        self.size=size
        self.string=attributed
        self.setGeometry()
        self.setTextLayer()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal override init() {
        super.init()
    }
    
    fileprivate func setGeometry() -> Void {
        if self.geometry==nil {
            let plane = SCNPlane.init()
            plane.materials.first?.isDoubleSided=true
            self.geometry=plane
        }
        let plane = self.geometry as! SCNPlane
        plane.width=self.size.width
        plane.height=self.size.height
    }
    fileprivate func setTextLayer() -> Void {
        DispatchQueue.main.async {
            if self.textLayer==nil {
                self.textLayer=AttachTextLayer.init()
                self.geometry!.materials.first!.diffuse.contents=self.textLayer!
            }
            let w = self.size.width*UIScreen.main.bounds.size.width*10
            let h = self.size.height*(w/self.size.width)
            self.textLayer?.frame=CGRect.init(x: 0, y: 0, width: w, height: h)
            self.textLayer?.string=self.string
            self.textLayer?.font=self.font
            self.textLayer?.fontSize=self.fontSize
            self.textLayer?.foregroundColor=self.foregroundColor?.cgColor
            self.textLayer?.isWrapped=self.isWrapped
            self.textLayer?.truncationMode=self.truncationMode
            self.textLayer?.alignmentMode=self.alignmentMode
            self.textLayer?.allowsFontSubpixelQuantization=self.allowsFontSubpixelQuantization
        }
    }
}
