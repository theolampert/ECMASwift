import JavaScriptCore
import os

@objc protocol ConsoleExports: JSExport {
    static func log(_ msg: String)
    static func info(_ msg: String)
    static func warn(_ msg: String)
    static func error(_ msg: String)
}

/// This implmenets the `Console` browser API.
///
/// Reference: [Console Reference on MDN](https://developer.mozilla.org/en-US/docs/Web/API/Console)
final class Console: NSObject, ConsoleExports {
    static let logger = Logger(subsystem: "JSRuntime", category: "Console")

    public class func log(_ msg: String) {
        logger.log("\(msg)")
    }

    public class func info(_ msg: String) {
        logger.info("\(msg)")
    }

    public class func warn(_ msg: String) {
        logger.warning("\(msg)")
    }

    public class func error(_ msg: String) {
        logger.error("\(msg)")
    }
}

/// Helper to register the ``Console`` API with a context.
public struct ConsoleAPI {
    public func registerAPIInto(context: JSContext) {
        context.setObject(
            Console.self,
            forKeyedSubscript: "console" as NSCopying & NSObjectProtocol
        )
    }
}
