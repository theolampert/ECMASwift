import JavaScriptCore
import JSValueCoder

// https://developer.mozilla.org/en-US/docs/Web/API/URLSearchParams

@objc 
protocol URLSearchParamsExports: JSExport {
    var params: [String: [String]] { get }
    func append(_ key: String, _ value: String)
    func getAll(_ key: String) -> [String]?
    func get(_ key: String) -> String?
    func set(_ key: String, _ value: String)
    func delete(_ key: String)
    func toString() -> String
}

/// This implmenets the `URLSearchParams` browser API.
///
/// Reference: [URLSearchParams Reference on MDN](https://developer.mozilla.org/en-US/docs/Web/API/URLSearchParams)
final class URLSearchParams: NSObject, URLSearchParamsExports, Decodable, Encodable {
    private var orderedKeys: [String] = []
    var params: [String: [String]] = [:]

    init(_ query: String = "") {
        super.init()
        parse(query)
    }

    func parse(_ query: String) {
        let pairs = query.split(separator: "&")
        for pair in pairs {
            let keyValue = pair.split(separator: "=")
            let key = String(keyValue[0])
            let value = String(keyValue[1])
            append(key, value)
        }
    }

    func append(_ key: String, _ value: String) {
        if params[key] == nil {
            orderedKeys.append(key)
            params[key] = []
        }
        params[key]?.append(value)
    }

    func getAll(_ key: String) -> [String]? {
        return params[key]
    }

    func get(_ key: String) -> String? {
        return params[key]?.first
    }

    func set(_ key: String, _ value: String) {
        if params[key] == nil {
            orderedKeys.append(key)
        }
        params[key] = [value]
    }

    func delete(_ key: String) {
        params.removeValue(forKey: key)
        if let index = orderedKeys.firstIndex(of: key) {
            orderedKeys.remove(at: index)
        }
    }

    func toEncodedString() -> String {
        return queryString(from: params, using: { param in
            
            // Escape all non-alphanumerics with percent-codes and but spaces with + (instead of %20)
            // https://developer.mozilla.org/en-US/docs/Glossary/percent-encoding
            param.addingPercentEncoding(withAllowedCharacters: .alphanumerics)?
                .replacingOccurrences(of: "%20", with: "+")
        })
    }
    
    func toString() -> String {
        return queryString(from: params, using: nil)
    }
    
    private func queryString(from params: [String: [String]], using encoder: ((String) -> String?)?) -> String {
        var queryItems: [String] = []
        for key in orderedKeys {
            guard let values = params[key] else { continue }
            for value in values {
                if let encoder = encoder, let encodedValue = encoder(value) {
                    queryItems.append("\(key)=\(encodedValue)")
                } else {
                    queryItems.append("\(key)=\(value)")
                }
            }
        }
        return queryItems.joined(separator: "&")
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
