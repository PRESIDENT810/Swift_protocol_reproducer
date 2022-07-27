//
//  FooBar.swift
//  FrameworkA
//
//  Created by ByteDance on 2022/7/27.
//

import Foundation

public func foo(){
    var change: [NSKeyValueChangeKey: Any]? = [:]
    var key = NSKeyValueChangeKey.init(rawValue: "hello world")
    change![key] = "hello world"
    if let offset = change![.newKey] as? CGPoint{
        print(offset)
    }
}

public func bar(){
    var change: [RunLoop.Mode: Any]? = [:]
    var mode = RunLoop.Mode.init(rawValue: "hello world")
    change![mode] = "hello world"
    if let offset = change![mode] as? CGPoint{
        print(offset)
    }
}
