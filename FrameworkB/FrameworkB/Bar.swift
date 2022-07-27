//
//  File.swift
//  FrameworkB
//
//  Created by ByteDance on 2022/7/27.
//

import Foundation

public func bar(){
    var change: [RunLoop.Mode: Any]? = [:]
    var mode = RunLoop.Mode.init(rawValue: "hello world")
    change![mode] = "hello world"
    if let offset = change![mode] as? CGPoint{
        print(offset)
    }
}
