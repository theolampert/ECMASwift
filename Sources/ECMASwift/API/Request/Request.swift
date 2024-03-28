import Foundation
import JavaScriptCore

@objc
protocol RequestExports: JSExport {
    var url: String { get set }
    var method: String { get }
    var headers: Headers { get }
    var signal: AbortSignal? { get set }
    var bodyUsed: Bool { get }

    func text() -> String?
    func blob() -> JSValue?
    func clone() -> Request
    func formData() -> FormData?
}

/// This implmenets the `Request` browser API.
///
/// Reference: [Request Reference on MDN](https://developer.mozilla.org/en-US/docs/Web/API/Request)
final class Request: NSObject, RequestExports {
    var request: URLRequest
    var body: RequestBody?
    var bodyUsed: Bool = false
    var cache: String?
    var credentials: String?
    var destination: String?
    var integrity: String?
    var mode: String = "cors"
    var redirect: String?
    var referrer: String?
    var referrerPolicy: String = ""
    var signal: AbortSignal?

    weak var context: JSContext?

    init(url: String, options: JSValue? = nil) {
        let url = Foundation.URL(string: url)!
        self.request = URLRequest(url: url)
        self.request.httpMethod = "GET"

        if let options, options.hasValue {
            if options.hasProperty("method") {
                request.httpMethod = options.forProperty("method").toString()
            }
            if let body = options.forProperty("body") {
                self.body = RequestBody.create(from: body)
                request.httpBody = self.body?.data()
            }
            if let signal = options.forProperty("signal").toType(AbortSignal.self) {
                self.signal = signal
            }
            if let headers = options.forProperty("headers") {
                if let headersInstance = headers.toType(Headers.self) {
                    request.allHTTPHeaderFields = headersInstance.getAll()
                } else if let headersObject = headers.toDictionary() as? [String: String] {
                    request.allHTTPHeaderFields = Headers(withHeaders: headersObject).getAll()
                }
            }
        }
    }

    var url: String {
        get { request.url!.absoluteString }
        set(newValue) { request.url = Foundation.URL(string: newValue) }
    }

    var method: String {
        get { request.httpMethod! }
    }

    var headers: Headers {
        get {
            if let headers = request.allHTTPHeaderFields {
                return Headers(withHeaders: headers)
            }
            return Headers()
        }
        set(newValue) {
            self.request.allHTTPHeaderFields = newValue.getAll()
        }
    }

    // MARK: - Body Methods

    func arrayBuffer() -> Data? {
        bodyUsed = true
        return body?.data()
    }

    func blob() -> JSValue? {
        bodyUsed = true
        guard let context = context, let body = self.body else { return nil }

        return JSValue(newPromiseIn: context) { resolve, _ in
            let blob = Blob(content: body.string()!)
            blob.context = context
            resolve?.call(withArguments: [blob])
        }
    }

    func formData() -> FormData? {
        bodyUsed = true
        return nil
    }

    func json() -> Any? {
        bodyUsed = true
        guard let data = body?.data() else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: [])
    }

    func text() -> String? {
        bodyUsed = true
        return body?.string()
    }

    func clone() -> Request {
        let request = Request(url: url)
        request.request = self.request
        return request
    }
}

/// Helper to register the ``Request`` API with a context.
struct RequestAPI {
    func registerAPIInto(context: JSContext) {
        let requestClass: @convention(block) (String, JSValue?) -> Request = { url, options in
            let request: Request
            if let options = options, options.hasValue {
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
