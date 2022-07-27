//
//  main.swift
//  hash
//
//  Created by ByteDance on 2022/7/25.
//

import Foundation
import FrameworkA
import FrameworkB

func main(){
    var change: [NSKeyValueChangeKey: Any]? = [:]
    var key = NSKeyValueChangeKey.init(rawValue: "hello world")
    change![key] = "hello world"
}

main()
