//
//  Console.swift
//  
//
//  Created by Theodore Lampert on 07.06.23.
//

import JavaScriptCore

@objc protocol ConsoleExports: JSExport {
    static func log(_ msg: String)
    static func info(_ msg: String)
    static func warn(_ msg: String)
    static func error(_ msg: String)
}

class Console: NSObject, ConsoleExports {
    class public func log(_ msg: String) {
        print(msg)
    }

    class public func info(_ msg: String) {
        print(msg)
    }

    class public func warn(_ msg: String) {
        print(msg)
    }

    class public func error(_ msg: String) {
        print(msg)
    }
}

public struct ConsoleAPI {
    public func registerAPIInto(context: JSContext) {
        context.setObject(
            Console.self,
            forKeyedSubscript: "console" as NSCopying & NSObjectProtocol
        )
    }
}
