//
//  JSContext+callAsyncFunction.swift
//
//
//  Created by Theodore Lampert on 07.06.23.
//

import JavaScriptCore

public extension JSContext {
    func callAsyncFunction(key: String, withArguments: [Any] = []) async throws -> JSValue {
        try await withCheckedThrowingContinuation { continuation in
            let onFulfilled: @convention(block) (JSValue) -> Void = {
                continuation.resume(returning: $0)
            }
            let onRejected: @convention(block) (JSValue) -> Void = {
                let error = NSError(
                    domain: key,
                    code: 0,
                    userInfo: [NSLocalizedDescriptionKey: "\($0)"]
                )
                continuation.resume(throwing: error)
            }
            let promiseArgs = [
                unsafeBitCast(onFulfilled,
                              to: JSValue.self),
                unsafeBitCast(onRejected,
                              to: JSValue.self),
            ]

            let promise = self.objectForKeyedSubscript(key)
                .call(withArguments: withArguments)
            promise?.invokeMethod("then", withArguments: promiseArgs)
        }
    }
    
    func invokeAsyncMethod(key: String, methodKey: String, withArguments: [Any] = []) async throws -> JSValue {
        try await withCheckedThrowingContinuation { continuation in
            let onFulfilled: @convention(block) (JSValue) -> Void = {
                continuation.resume(returning: $0)
            }
            let onRejected: @convention(block) (JSValue) -> Void = {
                let error = NSError(
                    domain: key,
                    code: 0,
                    userInfo: [NSLocalizedDescriptionKey: "\($0)"]
                )
                continuation.resume(throwing: error)
            }
            let promiseArgs = [
                unsafeBitCast(onFulfilled,
                              to: JSValue.self),
                unsafeBitCast(onRejected,
                              to: JSValue.self),
            ]

            let promise = self.objectForKeyedSubscript(key)
                .invokeMethod(methodKey, withArguments: withArguments)
            promise?.invokeMethod("then", withArguments: promiseArgs)
        }
    }
}
