import JavaScriptCore

public extension JSContext {
    func callFunction(key: String, withArguments: [Any] = []) throws -> JSValue? {
        return self.objectForKeyedSubscript(key)
            .call(withArguments: withArguments)
    }
}
