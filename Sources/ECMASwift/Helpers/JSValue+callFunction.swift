import JavaScriptCore

public extension JSValue {

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

            let promise = call(withArguments: withArguments)
            promise?.invokeMethod("then", withArguments: promiseArgs)
        }
    }

    /// Calls an async function `methodKey` on the object identified by `key`.
    ///
    /// - Parameters:
    ///   - methodKey: The identifier of the method
    ///   - withArguments: Optional arguments
    /// - Returns: The return value of the function
    func invokeAsyncMethod(methodKey: String, withArguments: [Any] = []) async throws -> JSValue {
        try await withCheckedThrowingContinuation { continuation in

           let onFulfilled: @convention(block) (JSValue) -> Void = {
                continuation.resume(returning: $0)
           }

           let onRejected: @convention(block) (JSValue) -> Void = { error in
               let nsError = JSContext.getErrorFrom(key: methodKey, error: error)
               continuation.resume(throwing: nsError)
           }

           let promiseArgs = [
               unsafeBitCast(onFulfilled, to: JSValue.self),
               unsafeBitCast(onRejected, to: JSValue.self)
           ]

           guard let promise = invokeMethod(methodKey, withArguments: withArguments),
                promise.hasValue else {
                   let error = NSError(
                       domain: methodKey,
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
