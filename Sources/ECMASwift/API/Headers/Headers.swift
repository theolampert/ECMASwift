import JavaScriptCore

@objc
protocol HeadersExports: JSExport {
    func set(_ key: String, _ value: String)
    func get(_ key: String) -> String?
    func delete(_ key: String)
    func getAll() -> [String: String]
}

/// This implmenets the `Headers` browser API.
///
/// Reference: [Headers Reference on MDN](https://developer.mozilla.org/en-US/docs/Web/API/Headers)
final class Headers: NSObject, HeadersExports {
    private var headers: [String: String] = [:]

    init(withHeaders: [String: String] = [:]) {
        super.init()
        for (key, value) in withHeaders {
            self.set(key, value)
        }
    }

    public func set(_ key: String, _ value: String) {
        headers[key] = value
    }

    public func get(_ key: String) -> String? {
        return headers[key]
    }

    public func delete(_ key: String) {
        headers.removeValue(forKey: key)
    }

    public func getAll() -> [String: String] {
        return headers
    }
}

/// Helper to register the ``Headers`` API with a context.
struct HeadersAPI {
    func registerAPIInto(context: JSContext) {
        let headersClass: @convention(block) () -> Headers = {
            Headers()
        }
        context.setObject(
            unsafeBitCast(headersClass, to: AnyObject.self),
            forKeyedSubscript: "Headers" as NSString
        )
    }
}
