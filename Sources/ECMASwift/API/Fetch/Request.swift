import Foundation
import JavaScriptCore

// https://developer.mozilla.org/en-US/docs/Web/API/Request

//enum HTTPMethod: String, Codable {
//    case get
//    case put
//    case delete
//    case post
//}
//
//struct Body: Codable {
//    let json: String?
//    let form: URLSearchParams?
//
//    init(json: String) {
//        self.json = json
//        form = nil
//    }
//
//    init(form: URLSearchParams) {
//        json = nil
//        self.form = form
//    }
//
//    var value: Any? {
//        if let json = json {
//            return json
//        } else if let form = form {
//            return form
//        }
//        return nil
//    }
//
//    init(from decoder: Decoder) throws {
//        let container = try decoder.singleValueContainer()
//
//        if let value = try? container.decode(URLSearchParams.self) {
//            json = nil
//            form = value
//        } else if let value = try? container.decode(String.self) {
//            json = value
//            form = nil
//        } else {
//            throw DecodingError.typeMismatch(
//                Body.self,
//                DecodingError.Context(
//                    codingPath: decoder.codingPath,
//                    debugDescription: "Invalid property type"
//                )
//            )
//        }
//    }
//
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.singleValueContainer()
//
//        if let json = json {
//            try container.encode(json)
//        } else if let form = form {
//            try container.encode(form)
//        } else {
//            throw EncodingError.invalidValue(
//                self,
//                EncodingError.Context(
//                    codingPath: encoder.codingPath,
//                    debugDescription: "Invalid property value"
//                )
//            )
//        }
//    }
//}

//struct Request: Codable {
//    let body: Body?
//    let credentials: String?
//    let method: HTTPMethod?
//    let headers: [String: String]?
//    let mode: String?
//}

// TODO: Probably eventually needs to model a ReadableStream properly
enum Body: Codable {
    case blob(Data)
    case arrayBuffer(Data)
    case typedArray(Data)
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
    
    func arrayBuffer() {}
    
    func blob() {}
    
    func clone() {}
    
    func formData() {}
    
    func json() {}
    
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
