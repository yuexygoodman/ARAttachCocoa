//
//  AttachImage.swift
//  ARAttachCocoa
//
//  Created by Good Man on 2018/8/31.
//  Copyright © 2018年 Good Man. All rights reserved.
//

import UIKit
import SceneKit

open class AttachImage: AttachControl {
    public var size:CGSize=CGSize.zero {
        didSet {
            self.setGeometry()
        }
    }
    public var img:UIImage? {
        didSet {
            self.setImageLayer()
        }
    }
    public var placeholder:UIImage? {
        didSet {
            self.setImageLayer()
        }
    }
    public var imgUrl:NSURL? {
        didSet {
            self.setImageLayer()
        }
    }
    public convenience init(with size:CGSize) {
        self.init(with: size, img: nil)
    }
    public init(with size:CGSize, img:UIImage?,placeholder:UIImage?=nil) {
        super.init()
        self.size = size
        self.img=img
        self.setGeometry()
        self.setImageLayer()
    }
    public init(with size:CGSize, url:NSURL?,placeholder:UIImage?=nil) {
        super.init()
        self.size=size
        self.imgUrl=url
        self.setGeometry()
        self.setImageLayer()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    internal override init() {
        super.init()
    }
    func setGeometry() -> Void {
        if self.geometry == nil {
            let plane = SCNPlane.init()
            plane.materials.first?.isDoubleSided=true
            self.geometry=plane
        }
        let plane = self.geometry as! SCNPlane
        plane.width=self.size.width
        plane.height=self.size.height
    }
    func setImageLayer() -> Void {
        let plane = self.geometry as! SCNPlane
        plane.materials.first!.diffuse.contents = self.img ?? self.placeholder
        if self.img==nil && self.imgUrl != nil {
            //download and reset.
        }
    }
}
