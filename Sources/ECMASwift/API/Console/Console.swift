//
//  Console.swift
//  
//
//  Created by Theodore Lampert on 07.06.23.
//

import JavaScriptCore

@objc public protocol ConsoleExports: JSExport {
    func log(_ msg: String)
    func info(_ msg: String)
    func warn(_ msg: String)
    func error(_ msg: String)
}

@objc public class Console: NSObject, ConsoleExports {
    public func log(_ msg: String) {
        print(msg)
    }

    public func info(_ msg: String) {
        print(msg)
    }

    public func warn(_ msg: String) {
        print(msg)
    }

    public func error(_ msg: String) {
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
