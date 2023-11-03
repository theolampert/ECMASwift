import Foundation
import JavaScriptCore

// https://developer.mozilla.org/en-US/docs/Web/API/URL

@objc 
protocol URLExports: JSExport {
    var `protocol`: String { get set }
    var hostname: String { get set }
    var host: String { get set }
    var pathname: String { get set }
    var port: String { get set }
    var origin: String { get set }
    var searchParams: URLSearchParams { get }
    var search: String { get set }
    var fragment: String { get set }
    func toString() -> String
}


/// This implmenets the `URL` browser API.
///
/// Reference: [URL Reference on MDN](https://developer.mozilla.org/en-US/docs/Web/API/URL)
final class URL: NSObject, URLExports {
    var url: Foundation.URL?

    init(string: String) {
        super.init()
        url = Foundation.URL(string: string)
    }
    
    init(string: String, base: String?) {
        super.init()
        if let base = base, let baseURL = Foundation.URL(string: base) {
            url = Foundation.URL(string: string, relativeTo: baseURL)
        } else {
            url = Foundation.URL(string: string)
        }
    }

    init(url: Foundation.URL) {
        super.init()
        self.url = url
    }

    func toString() -> String {
        if let url = url, !searchParams.toEncodedString().isEmpty {
            return url.absoluteString + "?" + searchParams.toEncodedString()
        }
        return url?.absoluteString ?? ""
    }

    func setURLComponent<T>(_ key: WritableKeyPath<URLComponents, T>, value: T) {
        guard let url = url else { return }
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?[keyPath: key] = value
        self.url = components?.url
    }

    var `protocol`: String {
        get { return url?.scheme ?? "" }
        set(newValue) { setURLComponent(\.scheme, value: newValue) }
    }

    var hostname: String {
        get { return url?.host ?? "" }
        set(newValue) { setURLComponent(\.host, value: newValue) }
    }

    var host: String {
        get { return url?.host ?? "" }
        set(newValue) { setURLComponent(\.host, value: newValue) }
    }

    var pathname: String {
        get { return url?.path ?? "" }
        set(newValue) { setURLComponent(\.path, value: newValue) }
    }

    var origin: String {
        get {
            guard let scheme = url?.scheme, let host = url?.host else {
                return ""
            }

            var origin = "\(scheme)://\(host)"

            if let port = url?.port {
                origin.append(":\(port)")
            }

            return origin
        }
        set(newValue) {
            setURLComponent(\.host, value: newValue)
        }
    }

    var port: String {
        get {
            guard let port = url?.port else { return "" }
            return String(port)
        }
        set(newValue) { setURLComponent(\.port, value: Int(newValue)) }
    }

    var searchParams: URLSearchParams = URLSearchParams("")
    
    var search: String {
        get {
            guard let query = url?.query else { return "" }
            return "?" + query
        }
        set(newValue) {
            setURLComponent(\.query, value: newValue)
        }
    }
    
    /// The actual property should be exposed as `hash` but this colides with `NSObject`, this isn't used anyway.
    /// Objective-C offers the macro `ExportAs` however there isn't a Swift equivalent.
    var fragment: String {
        get {
            guard let fragment = url?.fragment else { return "" }
            return "#" + fragment
        }
        set(newValue) {
            setURLComponent(\.fragment, value: newValue)
        }
    }
}

/// Helper to register the ``URL`` API with a context.
public struct URLAPI {
    public func registerAPIInto(context: JSContext) {
        let urlClass: @convention(block) (String, JSValue?) -> URL = { string, baseValue in
            if let baseValue = baseValue, !baseValue.isUndefined, !baseValue.isNull {
                return URL(string: string, base: baseValue.toString())
            } else {
                return URL(string: string)
            }
        }
        
        context.setObject(
            urlClass,
            forKeyedSubscript: "URL" as NSString
        )
    }
}
