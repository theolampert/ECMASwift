import Foundation
import JavaScriptCore

/// Models a request body.
///
/// Reference: [Request Reference on MDN](https://developer.mozilla.org/en-US/docs/Web/API/Request/body)
enum RequestBody {
    case blob
    case arrayBuffer
    case typedArray
    case formData(FormData)
    case urlSearchParams(URLSearchParams)
    case object([AnyHashable: Any])
    case string(String)
    
    static func create(from jsValue: JSValue) -> RequestBody? {
        guard jsValue.isNotNil else { return nil }
        if let searchParams = jsValue.toType(URLSearchParams.self) {
            return .urlSearchParams(searchParams)
        } else if let formData = jsValue.toType(FormData.self) {
            return .formData(formData)
        } else if let string = jsValue.toString() {
            return .string(string)
        } else if let object = jsValue.toDictionary() {
            return .object(object)
        } else {
            return nil
        }
    }
    
    func data() -> Data? {
        switch self {
        case .urlSearchParams(let searchParams):
            return searchParams.toEncodedString().data(using: .utf8)
        case .string(let string):
            return string.data(using: .utf8)
        case .object(let object):
            let data = try? JSONSerialization.data(withJSONObject: object)
            return data
        default:
            return nil
        }
    }
    
    func string() -> String? {
        switch self {
        case .urlSearchParams(let searchParams):
            return searchParams.toString()
        case .string(let string):
            return string
        case .object(let object):
            let data = try! JSONSerialization.data(withJSONObject: object)
            return String(data: data, encoding: .utf8)
        default:
            return nil
        }
    }
}
