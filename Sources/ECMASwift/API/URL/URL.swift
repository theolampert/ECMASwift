import Foundation
import JavaScriptCore

// https://developer.mozilla.org/en-US/docs/Web/API/URL

@objc protocol URLExports: JSExport {
    var `protocol`: String { @objc get @objc set }
    var hostname: String { @objc get @objc set }
    var host: String { @objc get @objc set }
    var pathname: String { @objc get @objc set }
    var port: String { @objc get @objc set }
    var origin: String { @objc get @objc set }
    var searchParams: URLSearchParams { @objc get }
    func toString() -> String
}

class URL: NSObject, URLExports {
    var url: Foundation.URL?
    
    init(string: String) {
        super.init()
        url = Foundation.URL(string: string)
    }
    
    init(url: Foundation.URL) {
        super.init()
        self.url = url
    }
    
    func toString() -> String {
        if let url = url, !searchParams.toString().isEmpty {
            return url.absoluteString + "?" + searchParams.toString()
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
        get { return url?.host ?? "" }
        set(newValue) { setURLComponent(\.host, value: newValue) }
    }
    
    var port: String {
        get {
            guard let port = url?.port else { return "" }
            return String(port)
        }
        set(newValue) { setURLComponent(\.port, value: Int(newValue)) }
    }
    
    var searchParams: URLSearchParams {
        get { URLSearchParams("") }
    }
}

public struct URLAPI {
    public func registerAPIInto(context: JSContext) {
        let urlClass: @convention(block) (String) -> URL = { string in
            URL(string: string)
        }
        context.setObject(
            unsafeBitCast(urlClass, to: AnyObject.self),
            forKeyedSubscript: "URL" as NSString
        )
    }
}
