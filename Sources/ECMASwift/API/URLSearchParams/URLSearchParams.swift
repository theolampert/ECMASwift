//
//  URLSearchParams.swift
//  
//
//  Created by Theodore Lampert on 14.05.23.
//

import Foundation
import JavaScriptCore
import JSValueCoder

@objc protocol URLSearchParamsExports: JSExport {
    var params: [String: [String]] { get }
    
    func append(_ key: String, _ value: String)
    func getAll(_ key: String) -> [String]?
    func get(_ key: String) -> String?
    func set(_ key: String, _ value: String)
    func delete(_ key: String)
    func toString() -> String
}

@objc class URLSearchParams: NSObject, URLSearchParamsExports, Decodable, Encodable {
    var params: [String: [String]] = [:]
    
    func parse(_ query: String) {
        let pairs = query.split(separator: "&")
        for pair in pairs {
            let keyValue = pair.split(separator: "=")
            let key = String(keyValue[0])
            let value = String(keyValue[1])
            append(key, value)
        }
    }
    
    public func append(_ key: String, _ value: String) {
        if params[key] == nil {
            params[key] = []
        }
        params[key]?.append(value)
    }
    
    public func getAll(_ key: String) -> [String]? {
        return params[key]
    }
    
    public func get(_ key: String) -> String? {
        return params[key]?.first
    }
    
    public func set(_ key: String, _ value: String) {
        params[key] = [value]
    }
    
    public func delete(_ key: String) {
        params.removeValue(forKey: key)
    }
    
    public func toString() -> String {
        var queryItems: [String] = []
        for (key, values) in params {
            for value in values {
                let item = "\(key)=\(value)"
                queryItems.append(item)
            }
        }
        return queryItems.joined(separator: "&")
    }
}

public struct URLSearchParamsAPI {
    public func registerAPIInto(context: JSContext) {
        let searchParamsClass: @convention(block) () -> URLSearchParams = {
            return URLSearchParams()
        }
        context.setObject(
            unsafeBitCast(searchParamsClass, to: AnyObject.self),
            forKeyedSubscript: "URLSearchParams" as NSString
        )
    }
}
