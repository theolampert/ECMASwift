import JavaScriptCore

@objc protocol ConsoleExports: JSExport {
    static func log(_ msg: String)
    static func info(_ msg: String)
    static func warn(_ msg: String)
    static func error(_ msg: String)
}

class Console: NSObject, ConsoleExports {
    public class func log(_ msg: String) {
        print(msg)
    }

    public class func info(_ msg: String) {
        print(msg)
    }

    public class func warn(_ msg: String) {
        print(msg)
    }

    public class func error(_ msg: String) {
        print(msg)
    }
}

public struct ConsoleAPI {
    public func registerAPIInto(context: JSContext) {
        context.setObject(
            Console.self,
            forKeyedSubscript: "console" as NSCopying & NSObjectProtocol
        )
    }
}
