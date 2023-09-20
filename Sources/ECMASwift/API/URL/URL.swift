import Foundation
import JavaScriptCore

// https://url.spec.whatwg.org/#api

@objc protocol URLExports: JSExport {
    var `protocol`: String { @objc get @objc set }
    var hostname: String { @objc get @objc set }
    var pathname: String { @objc get @objc set }
    var searchParams: URLSearchParams { @objc get @objc set }
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
    
    var `protocol`: String {
        get {
            return url?.scheme ?? ""
        }
        set(newValue) {
            // TODO
        }
    }
    
    var hostname: String {
        get {
            return url?.host ?? ""
        }
        set(newValue) {
            // TODO
        }
    }
    
    var pathname: String {
        get {
            return url?.path ?? ""
        }
        set(newValue) {
            // TODO
        }
    }
    
    var searchParams: URLSearchParams = URLSearchParams()
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
