import JavaScriptCore

@objc
protocol AbortSignalExports: JSExport {
    var aborted: Bool { get set }
}

class AbortSignal: NSObject, AbortSignalExports {
    private var _aborted: Bool = false
    var aborted: Bool {
        get { return _aborted }
        set {
            _aborted = newValue
            if newValue == true {
                self.onAbort?()
            }
        }
    }
    
    var onAbort: (() -> Void)?
}

@objc
protocol AbortControllerExports: JSExport {
    var signal: AbortSignal { get set }
    func abort()
}

class AbortController: NSObject, AbortControllerExports {
    var signal = AbortSignal()
    
    func abort() {
        signal.aborted = true
    }
}

struct AbortControllerAPI {
    func registerAPIInto(context: JSContext) {
        let abortControllerClass: @convention(block) () -> AbortController = {
            AbortController()
        }
        let abortSignalClass: @convention(block) () -> AbortSignal = {
            AbortSignal()
        }

        context.setObject(
            abortSignalClass,
            forKeyedSubscript: "AbortSignal" as NSString
        )
        context.setObject(
            abortControllerClass,
            forKeyedSubscript: "AbortController" as NSString
        )
    }
}
