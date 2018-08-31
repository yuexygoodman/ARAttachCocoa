//
//  Features.swift
//  ARDemo
//
//  Created by Good Man on 2018/8/13.
//  Copyright © 2018年 Good Man. All rights reserved.
//

import Foundation
import SceneKit

public struct Feature:FragmentCombination {
    typealias FragmentType = Feature
    var index: Int=0
    var fragments: [Feature]=[]
    
    var block:((AttachControl)->Void)?=nil
    init() {
    }
    public init(with block:@escaping (AttachControl)->Void) {
        self.block=block
    }
    public mutating func flash(_ control:AttachControl) -> Void {
        if let block = self.block {
            block(control)
        }
        else{
            if var feature = self.next() {
                feature.flash(control)
            }
        }
    }
}

//wave
extension Feature {
    public static let wave = Feature.init { (_) in }
}

//shake
extension Feature {
    fileprivate static let shakeDown = Feature.init { (control) in
        let node:SCNNode = control
        node.position = SCNVector3.init(node.position.x, node.position.y, node.position.z-0.03)
    }
    fileprivate static let shakeUp = Feature.init { (control) in
        let node:SCNNode = control
        node.position = SCNVector3.init(node.position.x, node.position.y, node.position.z+0.03)
    }
    public static let shake:Feature = [.shakeDown,.shakeUp]
}

//explode
extension Feature {
    public static let explode = Feature.init { (control) in
        let node:SCNNode = control
        guard node.parent != nil else {
            return
        }
        let copyNode = node.clone()
        var rootNode = node.parent!
        while rootNode.parent != nil {
            rootNode=rootNode.parent!
        }
        copyNode.simdTransform = node.parent!.simdConvertTransform(node.simdTransform, to: rootNode)
        copyNode.simdPosition = float3(copyNode.simdPosition.x, copyNode.simdPosition.y, copyNode.simdPosition.z+0.001)
        copyNode.opacity = 0.7
        rootNode.addChildNode(copyNode)
        copyNode.runAction(SCNAction.sequence([SCNAction.group([SCNAction.scale(by: 4, duration: 0.2),SCNAction.fadeOpacity(to: 0, duration: 0.2)]),SCNAction.removeFromParentNode()]))
    }
}
