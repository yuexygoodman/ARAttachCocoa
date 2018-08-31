//
//  AttachVideo.swift
//  ARDemo
//
//  Created by Good Man on 2018/8/13.
//  Copyright © 2018年 Good Man. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import SceneKit

open class AttachVideo: AttachControl {
    public var size:CGSize=CGSize.zero {
        didSet {
            self.setGeometry()
        }
    }
    public var enabledFullScreen=false {
        didSet {
            if enabledFullScreen {
                self.add(handler: self.toFullScreen, for: .touch(.bo, .wave))
            }
            else {
                self.removeHandlers(for: .touch)
            }
        }
    }
    public weak var sceneView:AttachSceneView!
    public init(with size:CGSize,view:AttachSceneView) {
        super.init()
        self.size = size
        self.sceneView=view
        self.setGeometry()
        NotificationCenter.default.addObserver(self, selector: #selector(self.play), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    internal override init() {
        super.init()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func playForever(url:URL,preview:UIImage?=nil) -> Void {
        self.preview=preview
        self.url=url
        self.play()
    }
    deinit {
        self.videoPlayer?.removeObserver(self, forKeyPath: "status", context: nil)
    }
    
    fileprivate var url:URL? {
        didSet {
            if url != nil {
                self.setVideoPlayer()
            }
        }
    }
    fileprivate var preview:UIImage?
    fileprivate var videoPlayer:AVPlayer?
    fileprivate weak var screenTap:UITapGestureRecognizer!
    fileprivate weak var videoLayer:AVPlayerLayer?
    fileprivate weak var copyNode:SCNNode!
}

extension AttachVideo {
    fileprivate func setVideoPlayer() -> Void {
        let playerItem = AVPlayerItem.init(url: self.url!)
        if self.videoPlayer == nil {
            self.videoPlayer = AVPlayer.init(playerItem: playerItem)
            self.videoPlayer?.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions(rawValue: 0), context: nil)
        }
        else {
            self.videoPlayer?.replaceCurrentItem(with: playerItem)
        }
        self.geometry!.materials.first!.diffuse.contents=self.preview ?? self.videoPlayer
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let kp=keyPath,kp == "status",self.videoPlayer!.status == .readyToPlay{
            let plane = self.geometry!
            plane.materials.first!.diffuse.contents=self.videoPlayer
        }
    }
    fileprivate func setGeometry() -> Void {
        if self.geometry==nil {
            let plane = SCNPlane()
            plane.materials.first!.isDoubleSided=true
            self.geometry=plane
        }
        let plane=self.geometry as! SCNPlane
        plane.width=size.width
        plane.height=size.height
    }
    @objc fileprivate func play() -> Void {
        self.videoPlayer!.seek(to: CMTime(seconds: 0, preferredTimescale: 1))
        self.videoPlayer!.play()
    }
}

extension AttachVideo {
    fileprivate var toFullScreen:EventHandler {
        return { (_,_) in
            if let frame = self.sceneView.session.currentFrame {
                let copyNode = self.clone()
                self.copyNode=copyNode
                copyNode.simdTransform = self.parent!.simdConvertTransform(self.simdTransform, to: self.sceneView.scene.rootNode)
                self.sceneView.scene.rootNode.addChildNode(copyNode)
                let position1 = SCNVector3.init(copyNode.simdTransform.columns.3.x, copyNode.simdTransform.columns.3.y, copyNode.simdTransform.columns.3.z)
                self.isHidden=true
                SCNTransaction.begin()
                SCNTransaction.animationDuration=1
                
                let position2 = SCNVector3.init(frame.camera.transform.columns.3.x,frame.camera.transform.columns.3.y, frame.camera.transform.columns.3.z)
                let vector = SCNVector3.init(position2.x-position1.x, position2.y-position1.y, position2.z-position1.z)
                let scale:Float = 0.07/sqrtf(vector.x*vector.x+vector.y*vector.y+vector.z*vector.z) * -1
                copyNode.transform = SCNMatrix4Translate(SCNMatrix4(frame.camera.transform),vector.x*scale , vector.y*scale, vector.z*scale)
                
                copyNode.scale = SCNVector3.init(1.4, 1.3, 1)
                SCNTransaction.completionBlock={
                    if self.videoLayer != nil {
                        copyNode.isHidden=true
                        DispatchQueue.main.async {
                            self.videoLayer?.isHidden=false
                        }
                    }
                }
                SCNTransaction.commit()
                DispatchQueue.main.async {
                    let layer = AVPlayerLayer(player: self.videoPlayer)
                    layer.frame=CGRect(x: 0, y: 0, width: self.sceneView.bounds.size.height, height: self.sceneView.bounds.size.width)
                    layer.position = self.sceneView.center
                    layer.transform = CATransform3DMakeRotation(.pi/2, 0, 0, 1)
                    layer.isHidden=true
                    self.videoLayer=layer
                    self.sceneView.layer.addSublayer(layer)
                    let tap = UITapGestureRecognizer.init(target: self, action: #selector(self.screen_tap(tap:)))
                    self.sceneView.addGestureRecognizer(tap)
                    self.screenTap=tap
                }
            }
        }
    }
    @objc fileprivate func screen_tap(tap:UITapGestureRecognizer) -> Void {
        if self.copyNode.isHidden {
            self.sceneView.removeGestureRecognizer(self.screenTap)
            self.videoLayer?.removeFromSuperlayer()
            self.copyNode.isHidden=false
            SCNTransaction.begin()
            SCNTransaction.animationDuration=1.0
            SCNTransaction.completionBlock={
                self.copyNode.removeFromParentNode()
                self.isHidden=false
            }
            self.copyNode.simdTransform=self.origin
            SCNTransaction.commit()
        }
    }
    fileprivate var origin:simd_float4x4 {
        return self.parent!.simdConvertTransform(self.simdTransform, to: self.sceneView.scene.rootNode)
    }
}
