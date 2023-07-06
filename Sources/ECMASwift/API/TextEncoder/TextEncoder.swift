//
//  TextEncoder.swift
//  
//
//  Created by Theodore Lampert on 27.06.23.
//

import Foundation
import JavaScriptCore

@objc protocol TextEncoderExports: JSExport {
    func encode(_ input: String) -> Data?
}

class TextEncoder: NSObject, TextEncoderExports {
    func encode(_ input: String) -> Data? {
        if let data = input.data(using: .utf8) {
            return data
        }
        return nil
    }
}

public struct TextEncoderAPI {
    public func registerAPIInto(context: JSContext) {
        let textEncoderClass: @convention(block) () -> TextEncoder = {
            TextEncoder()
        }
        context.setObject(
            unsafeBitCast(textEncoderClass, to: AnyObject.self),
            forKeyedSubscript: "TextEncoder" as NSString
        )
    }
}
