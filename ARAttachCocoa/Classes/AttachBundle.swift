//
//  AttachBundle.swift
//  ARDemo
//
//  Created by Good Man on 2018/8/21.
//  Copyright © 2018年 Good Man. All rights reserved.
//

import Foundation

fileprivate let attach_bundle = Bundle.init(for: AttachControl.self)

extension Bundle {
    static var attach:Bundle {
        attach_bundle.load()
        return attach_bundle
    }
}
