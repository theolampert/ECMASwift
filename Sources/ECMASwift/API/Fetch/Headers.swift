//
//  Headers.swift
//  
//
//  Created by Theodore Lampert on 08.06.23.
//

import JavaScriptCore

@objc public protocol HeadersExports: JSExport {
    func setHeader(_ key: String, _ value: String)
    func getHeader(_ key: String) -> String?
    func deleteHeader(_ key: String)
    func getAllHeaders() -> [String: String]
}

class Headers: NSObject, HeadersExports {
    private var headers: [String: String] = [:]

    func setHeader(_ key: String, _ value: String) {
        headers[key] = value
    }

    func getHeader(_ key: String) -> String? {
        return headers[key]
    }

    func deleteHeader(_ key: String) {
        headers.removeValue(forKey: key)
    }

    func getAllHeaders() -> [String: String] {
        return headers
    }
}

class HeadersAPI {
    func registerAPIInto(context: JSContext) {
        context.setObject(
            Headers.self,
            forKeyedSubscript: "Headers" as NSCopying & NSObjectProtocol
        )
    }
}
