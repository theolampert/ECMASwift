import JavaScriptCore

public struct ECMASwift {
    public let context: JSContext = JSContext()
    
    public init() {
        registerAPI()
    }
    
    private func registerAPI() {
        FetchAPI().registerAPIInto(context: context)
        HeadersAPI().registerAPIInto(context: context)
        URLSearchParamsAPI().registerAPIInto(context: context)
        ConsoleAPI().registerAPIInto(context: context)
    }
}
