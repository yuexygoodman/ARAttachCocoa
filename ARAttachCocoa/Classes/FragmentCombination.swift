//
//  FragmentCombination.swift
//  ARDemo
//
//  Created by Good Man on 2018/8/17.
//  Copyright © 2018年 Good Man. All rights reserved.
//

import Foundation

protocol FragmentCombination:ExpressibleByArrayLiteral {
    associatedtype FragmentType where FragmentType==Self
    mutating func next() -> FragmentType?
    var index:Int{get set}
    var fragments:[FragmentType]{get set}
    init()
}

extension FragmentCombination {
    public init(arrayLiteral elements: FragmentType...) {
        self.init()
        for element in elements {
            fragments.append(element)
        }
    }
    mutating func next() -> FragmentType? {
        if index == fragments.count {
            index = 0
        }
        let fragment = fragments.count>index ? fragments[index] : nil
        index=index+1
        return fragment
    }
}
