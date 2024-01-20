import Foundation
import JavaScriptCore

// TODO: Implementation is unfinished as it encodes into the wrong format, but is currently unsued.

@objc
protocol FormDataExports: JSExport {
    func append(_ name: String, _ value: String)
    func get(_ name: String) -> String?
}

@objc
class FormData: NSObject, FormDataExports {
    private var queryItems: [URLQueryItem] = []

    func append(_ name: String, _ value: String) {
        let item = URLQueryItem(name: name, value: value)
        queryItems.append(item)
    }

    func get(_ name: String) -> String? {
        return queryItems.first { $0.name == name }?.value
    }

    func getAll(_ name: String) -> [String] {
        return queryItems.filter { $0.name == name }.compactMap { $0.value }
    }

    var serialized: String? {
        var components = URLComponents()
        components.queryItems = queryItems
        return components.percentEncodedQuery
    }
}

/// Helper to register the ``FormData`` API with a context.
public struct FormDataAPI {
    public func registerAPIInto(context: JSContext) {
        let formDataClass: @convention(block) (JSValue?) -> FormData = { _ in
            return FormData()
        }
        context.setObject(
            unsafeBitCast(formDataClass, to: AnyObject.self),
            forKeyedSubscript: "FormData" as NSString
        )
    }
}
