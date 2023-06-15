import JavaScriptCore

public struct ECMASwift {
    public let context: JSContext = .init()

    public init() {
        registerAPI()
    }

    private func registerAPI() {
        FetchAPI().registerAPIInto(context: context)
        HeadersAPI().registerAPIInto(context: context)
        URLSearchParamsAPI().registerAPIInto(context: context)
        ConsoleAPI().registerAPIInto(context: context)
        JSTimer.registerInto(jsContext: context)
    }
}
