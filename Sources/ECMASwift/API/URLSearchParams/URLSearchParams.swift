import JavaScriptCore

@objc
protocol URLSearchParamsExports: JSExport {
    func append(_ key: String, _ value: String)
    func getAll(_ key: String) -> [String]
    func get(_ key: String) -> String?
    func set(_ key: String, _ value: String)
    func delete(_ key: String)
    func toString() -> String
}

/// This implmenets the `URLSearchParams` browser API.
///
/// Reference: [URLSearchParams Reference on MDN](https://developer.mozilla.org/en-US/docs/Web/API/URLSearchParams)
@objc
final class URLSearchParams: NSObject, URLSearchParamsExports {
    private var urlComponents: URLComponents

    override init() {
        self.urlComponents = URLComponents()
        super.init()
    }

    init(_ query: String) {
        self.urlComponents = URLComponents()
        super.init()
        self.urlComponents.query = query
    }

    // Append a new query item
    func append(_ name: String, _ value: String) {
        let newItem = URLQueryItem(name: name, value: value)
        if urlComponents.queryItems != nil {
            urlComponents.queryItems?.append(newItem)
        } else {
            urlComponents.queryItems = [newItem]
        }
    }

    // Get all values for a specific query name
    func getAll(_ name: String) -> [String] {
        return urlComponents.queryItems?.filter { $0.name == name }.compactMap { $0.value } ?? []
    }

    // Get the first value for a specific query name
    func get(_ name: String) -> String? {
        return urlComponents.queryItems?.first(where: { $0.name == name })?.value
    }

    // Set a value for a specific query name, replacing existing values
    func set(_ name: String, _ value: String) {
        // Remove existing items
        urlComponents.queryItems = urlComponents.queryItems?.filter { $0.name != name }
        // Append the new item
        append(name, value)
    }

    // Delete all values for a specific query name
    func delete(_ name: String) {
        urlComponents.queryItems = urlComponents.queryItems?.filter { $0.name != name }
    }

    func toEncodedString() -> String {
        return queryString(using: { param in
            param.addingPercentEncoding(withAllowedCharacters: .alphanumerics)?
                .replacingOccurrences(of: "%20", with: "+")
        })
    }

    func toString() -> String {
        return queryString()
    }

    // Representation of query items as a percent-encoded string, similar to JavaScript's URLSearchParams.toString()
    private func queryString(using encoder: ((String) -> String?)? = nil) -> String {
        guard let queryItems = urlComponents.queryItems else {
            return ""
        }

        return queryItems.compactMap { item in
            guard let value = item.value else { return nil }
            if let encoder = encoder, let encodedValue = encoder(value) {
                return "\(item.name)=\(encodedValue)"
            } else {
                return "\(item.name)=\(value)"
            }
        }.joined(separator: "&")
    }
}

/// Helper to register the ``URLSearchParams`` API with a context.
public struct URLSearchParamsAPI {
    public func registerAPIInto(context: JSContext) {
        let searchParamsClass: @convention(block) (JSValue?) -> URLSearchParams = { query in
            if let query, !query.isUndefined, !query.isNull {
                return URLSearchParams(query.toString())
            }
            return URLSearchParams()
        }
        context.setObject(
            unsafeBitCast(searchParamsClass, to: AnyObject.self),
            forKeyedSubscript: "URLSearchParams" as NSString
        )
    }
}
