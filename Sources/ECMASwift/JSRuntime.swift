import JavaScriptCore

/// `JSRuntime` wraps a `JSContext` and implements a few missing browser APIs
/// (mostly networking related, fetch, request etc.), which are then registered with the context.
/// So, a `JSRuntime` can be used as headless browser to execute ``LTCore``.
///
/// The following browser APIs are implemented in Swift and added to the JSContext:
///
/// - ``Blob``
/// - ``AbortController``
/// - ``Request``
/// - ``Fetch``
/// - ``Headers``
/// - ``URLSearchParams``
/// - ``URL``
/// - ``Console``
/// - ``Timer``
/// - ``TextEncoder``
/// - ``Crypto``
public struct JSRuntime {
    public let context: JSContext = .init()

    public init(client: HTTPClient = URLSession.shared) {
        registerAPIs(client: client)
    }

    private func registerAPIs(client: HTTPClient) {
        // Runtime APIs
        BlobAPI().registerAPIInto(context: context)
        AbortControllerAPI().registerAPIInto(context: context)
        RequestAPI().registerAPIInto(context: context)
        FetchAPI(client: client).registerAPIInto(context: context)
        HeadersAPI().registerAPIInto(context: context)
        URLSearchParamsAPI().registerAPIInto(context: context)
        URLAPI().registerAPIInto(context: context)
        ConsoleAPI().registerAPIInto(context: context)
        Task {
            await TimerAPI().registerAPIInto(context: context)
        }
        TextEncoderAPI().registerAPIInto(context: context)
        CryptoAPI().registerAPIInto(context: context)
    }
}
