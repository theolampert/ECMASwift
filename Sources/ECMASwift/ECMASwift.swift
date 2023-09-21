import JavaScriptCore

public struct ECMASwift {
    public let context: JSContext = .init()

    public init() {
        registerAPI()
    }

    private func registerAPI() {
        // Runtime APIs
        RequestAPI().registerAPIInto(context: context)
        FetchAPI().registerAPIInto(context: context)
        HeadersAPI().registerAPIInto(context: context)
        URLSearchParamsAPI().registerAPIInto(context: context)
        URLAPI().registerAPIInto(context: context)
        ConsoleAPI().registerAPIInto(context: context)
        TimerAPI().registerIntoAPI(context: context)
        TextEncoderAPI().registerAPIInto(context: context)
        CryptoAPI().registerAPIInto(context: context)
    }
}
