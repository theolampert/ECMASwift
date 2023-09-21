import Foundation
import JavaScriptCore

// https://developer.mozilla.org/en-US/docs/Web/API/Request

// TODO: Probably eventually needs to model a ReadableStream properly
enum Body: Codable {
    case blob(Data)
    case arrayBuffer([Data])
    case typedArray([UInt])
    case dataView(Data)
    case formData(Data)
    case urlSearchParams(URLSearchParams)
    case string(String)
    
    static func createFrom(_ value: Any) throws -> Body? {
        switch value {
        case let value as URLSearchParams:
            return .urlSearchParams(value)
        case let value as String:
            return .string(value)
        default:
            return nil
        }
    }
    
    func data() -> Data? {
        switch self {
        case .blob(_):
            fatalError("Unimplemented")
        case .arrayBuffer(_):
            fatalError("Unimplemented")
        case .typedArray(_):
            fatalError("Unimplemented")
        case .dataView(_):
            fatalError("Unimplemented")
        case .formData(_):
            fatalError("Unimplemented")
        case .urlSearchParams(let uRLSearchParams):
            return uRLSearchParams.toString().data(using: .utf8)
        case .string(let string):
            return string.data(using: .utf8)
        }
    }
}

@objc public protocol RequestExports: JSExport {
    var url: String { get }
    var method: String? { get }
    
    func text() -> String?
}

@objc class Request: NSObject, RequestExports, Codable {
    var body: Body?
    var bodyUsed: Bool = false
    var cache: String?
    var credentials: String?
    var destination: String?
    var headers: String?
    var integrity: String?
    var method: String?
    var mode: String?
    var redirect: String?
    var referrer: String?
    var referrerPolicy: String?
//    var signal: AbortSignal
    var url: String
    
    
    init(url: String, options: [AnyHashable: Any]? = nil) {
        self.url = url
        
        if let options {
            self.method = options["method"] as? String
            if let body = options["body"] {
                self.body = try? .createFrom(body)
            }
        }
    }
    
    func arrayBuffer() -> Data? {
        return body?.data()
    }
    
    func blob() -> Data? {
        return body?.data()
    }
    
    func clone() -> Request {
        return Request(url: self.url)
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
        case .blob(_):
            fatalError("Unimplemented")
        case .arrayBuffer(_):
            fatalError("Unimplemented")
        case .typedArray(_):
            fatalError("Unimplemented")
        case .dataView(_):
            fatalError("Unimplemented")
        case .formData(_):
            fatalError("Unimplemented")
        case .urlSearchParams(let uRLSearchParams):
            return uRLSearchParams.toString()
        case .string(let string):
            return string
        case nil:
            return nil
        }
    }
}

struct RequestAPI {
    func registerAPIInto(context: JSContext) {
        let headersClass: @convention(block) (String, JSValue?) -> Request = { url, options in
            return Request(url: url, options: options?.toDictionary())
        }
        context.setObject(
            unsafeBitCast(headersClass, to: AnyObject.self),
            forKeyedSubscript: "Request" as NSString
        )
    }
}
