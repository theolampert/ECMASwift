import JavaScriptCore

public struct ECMASwift {
    public let context: JSContext = .init()

    public init() {
        registerAPIs()
    }

    private func registerAPIs() {
        // Runtime APIs
        BlobAPI().registerAPIInto(context: context)
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
