import Foundation
import JavaScriptCore

/// Models a request body.
///
/// Reference: [Request Reference on MDN](https://developer.mozilla.org/en-US/docs/Web/API/Request/body)
enum Body {
    case blob(Data)
    case arrayBuffer([Data])
    case typedArray([UInt])
    case dataView(Data)
    case formData(Data)
    case urlSearchParams(URLSearchParams)
    case string(String)

    static func createFrom(_ jsValue: JSValue) -> Body? {
        guard jsValue.isNotNil else { return nil }
        if let searchParamsValue = jsValue.toType(URLSearchParams.self) {
            return .urlSearchParams(searchParamsValue)
        } else if let stringValue = jsValue.toString() {
            return .string(stringValue)
        }
        return nil
    }

    func data() -> Data? {
        switch self {
        case .blob:
            fatalError("Unimplemented")
        case .arrayBuffer:
            fatalError("Unimplemented")
        case .typedArray:
            fatalError("Unimplemented")
        case .dataView:
            fatalError("Unimplemented")
        case .formData:
            fatalError("Unimplemented")
        case let .urlSearchParams(urlSearchParams):
            // The browser's URLSearchParams API will change encoding based on the context it's used in...
            if let data = urlSearchParams.toEncodedString().data(using: .utf8) {
                return data
            }
            return nil
        case let .string(string):
            return string.data(using: .utf8)
        }
    }

    func string() -> String? {
        switch self {
        case .blob:
            fatalError("Unimplemented")
        case .arrayBuffer:
            fatalError("Unimplemented")
        case .typedArray:
            fatalError("Unimplemented")
        case .dataView:
            fatalError("Unimplemented")
        case .formData:
            fatalError("Unimplemented")
        case let .urlSearchParams(urlSearchParams):
            return urlSearchParams.toString()
        case let .string(string):
            return string
        }
    }
}

@objc 
protocol RequestExports: JSExport {
    var url: String { get set }
    var method: String { get }
    var headers: Headers { get }
    var signal: AbortSignal? { get set }

    func text() -> String?
    func blob() -> JSValue?
    func clone() -> Request
}


/// This implmenets the `Request` browser API.
///
/// Reference: [Request Reference on MDN](https://developer.mozilla.org/en-US/docs/Web/API/Request)
final class Request: NSObject, RequestExports {
    var body: Body?
    var bodyUsed: Bool = false
    var cache: String?
    var credentials: String?
    var destination: String?
    var headers: Headers = Headers()
    var integrity: String?
    var method: String = "GET"
    var mode: String?
    var redirect: String?
    var referrer: String?
    var referrerPolicy: String = ""
    var signal: AbortSignal?
    var url: String = ""

    weak var context: JSContext?

    init(url: String, options: JSValue? = nil) {
        self.url = url

        if let options {
            method = options.forProperty("method").toString()
            if let body = options.forProperty("body") {
                self.body = Body.createFrom(body)
            }
            if let signal = options.forProperty("signal").toType(AbortSignal.self) {
                self.signal = signal
            }
            if let headers = options.forProperty("headers") {
                if let headersInstance = headers.toType(Headers.self) {
                    self.headers = headersInstance
                } else if let headersObject = headers.toDictionary() as? [String: String] {
                    self.headers = Headers(withHeaders: headersObject)
                }
            }
        }
    }

    func arrayBuffer() -> Data? {
        return body?.data()
    }

    func blob() -> JSValue? {
        guard let context = context else {
            fatalError("JSContext is nil")
        }

        return JSValue(newPromiseIn: context) { resolve, _ in
            let blob = Blob(content: self.body!.string()!)
            blob.context = context
            resolve?.call(withArguments: [blob])
        }
    }

    func clone() -> Request {
        let request = Request(url: url)
        request.method = self.method
        request.credentials = self.credentials
        request.headers = self.headers
        
        return request
    }

    func formData() -> [String: String]? {
        guard case let .formData(data) = body else { return nil }
        let formString = String(data: data, encoding: .utf8) ?? ""
        var formData: [String: String] = [:]

        formString.components(separatedBy: "&").forEach {
            let keyValue = $0.components(separatedBy: "=")
            if keyValue.count == 2 {
                formData[keyValue[0]] = keyValue[1]
            }
        }
        return formData
    }

    func json() -> Any? {
        guard let data = body?.data() else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: [])
    }

    func text() -> String? {
        switch body {
        case .blob:
            fatalError("Unimplemented")
        case .arrayBuffer:
            fatalError("Unimplemented")
        case .typedArray:
            fatalError("Unimplemented")
        case .dataView:
            fatalError("Unimplemented")
        case .formData:
            fatalError("Unimplemented")
        case let .urlSearchParams(uRLSearchParams):
            return uRLSearchParams.toString()
        case let .string(string):
            return string
        case nil:
            return nil
        }
    }
}

/// Helper to register the ``Request`` API with a context.
struct RequestAPI {
    func registerAPIInto(context: JSContext) {
        let requestClass: @convention(block) (String, JSValue?) -> Request = { url, options in
            let request: Request
            if let options = options, !options.isUndefined, !options.isNull {
                request = Request(url: url, options: options)
            } else {
                request = Request(url: url)
            }
            request.context = context
            return request
        }

        context.setObject(
            requestClass,
            forKeyedSubscript: "Request" as NSString
        )
    }
}
