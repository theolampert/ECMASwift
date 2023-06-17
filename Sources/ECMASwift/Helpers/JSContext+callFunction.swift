//
//  JSContext+callFunction.swift
//  
//
//  Created by Theodore Lampert on 17.06.23.
//

import JavaScriptCore

extension JSContext {
    func callFunction(key: String, withArguments: [Any] = []) throws -> JSValue? {
        return self.objectForKeyedSubscript(key)
            .call(withArguments: withArguments)
    }
}
