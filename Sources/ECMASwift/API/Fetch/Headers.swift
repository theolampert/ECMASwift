import JavaScriptCore

// https://developer.mozilla.org/en-US/docs/Web/API/Headers

@objc public protocol HeadersExports: JSExport {
    func setHeader(_ key: String, _ value: String)
    func getHeader(_ key: String) -> String?
    func deleteHeader(_ key: String)
    func getAllHeaders() -> [String: String]
}

class Headers: NSObject, HeadersExports, Codable {
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
        let headersClass: @convention(block) () -> Headers = {
            Headers()
        }
        context.setObject(
            unsafeBitCast(headersClass, to: AnyObject.self),
            forKeyedSubscript: "Headers" as NSString
        )
    }
}
