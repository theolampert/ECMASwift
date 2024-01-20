import JavaScriptCore

public extension JSContext {
    func callFunction(key: String, withArguments: [Any] = []) throws -> JSValue? {
        return objectForKeyedSubscript(key)
            .call(withArguments: withArguments)
    }

    static func getErrorFrom(key: String, error: JSValue) -> NSError {
        var userInfo: [String: Any] = [:]

        if error.isObject {
            userInfo = error.toDictionary() as? [String: Any] ?? [:]
        } else {
            userInfo[NSLocalizedDescriptionKey] = error.toString() ?? "UnknownError"
        }

        return NSError(domain: key, code: 0, userInfo: userInfo)
    }

    /// Calls and invidual async function identified by `key`.
    ///
    /// - Parameters:
    ///   - key: The subscript key / identifier of the function
    ///   - withArguments: Optional arguments
    /// - Returns: The return value of the function
    func callAsyncFunction(key: String, withArguments: [Any] = []) async throws -> JSValue {
        try await withCheckedThrowingContinuation { continuation in
            let onFulfilled: @convention(block) (JSValue) -> Void = {
                continuation.resume(returning: $0)
            }
            let onRejected: @convention(block) (JSValue) -> Void = { error in
                let nsError = JSContext.getErrorFrom(key: key, error: error)
                continuation.resume(throwing: nsError)
            }
            let promiseArgs = [
                unsafeBitCast(onFulfilled, to: JSValue.self),
                unsafeBitCast(onRejected, to: JSValue.self)
            ]

            let promise = self.objectForKeyedSubscript(key)
                .call(withArguments: withArguments)
            promise?.invokeMethod("then", withArguments: promiseArgs)
        }
    }

    /// Calls an async function `methodKey` on the object identified by `key`.
    ///
    /// - Parameters:
    ///   - methodKey: The identifier of the method
    ///   - withArguments: Optional arguments
    /// - Returns: The return value of the function
    func invokeAsyncMethod(key: String, methodKey: String, withArguments: [Any] = []) async throws -> JSValue {
        try await withCheckedThrowingContinuation { continuation in

           let onFulfilled: @convention(block) (JSValue) -> Void = {
                continuation.resume(returning: $0)
           }

           let onRejected: @convention(block) (JSValue) -> Void = { error in
               let nsError = JSContext.getErrorFrom(key: key, error: error)
               continuation.resume(throwing: nsError)
           }

           let promiseArgs = [
               unsafeBitCast(onFulfilled, to: JSValue.self),
               unsafeBitCast(onRejected, to: JSValue.self)
           ]

           guard let promise = self.objectForKeyedSubscript(key).invokeMethod(methodKey, withArguments: withArguments),
                promise.hasValue else {
                   let error = NSError(
                       domain: key,
                       code: 1,
                       userInfo: [
                           NSLocalizedDescriptionKey: "JavaScript execution failed or returned an unexpected value."
                       ]
                   )
                   continuation.resume(throwing: error)
                   return
           }

           promise.invokeMethod("then", withArguments: promiseArgs)
       }
    }

}
