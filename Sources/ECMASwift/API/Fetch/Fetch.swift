@preconcurrency import JavaScriptCore

/// This implmenets the `Fetch` browser API.
///
/// Reference: [Fetch API Reference on MDN](https://developer.mozilla.org/en-US/docs/Web/API/Fetch_API)
public final class FetchAPI {
    let client: HTTPClient

    public init(client: HTTPClient) {
        self.client = client
    }

    static func text(data: Data, context: JSContext) -> Any? {
        return JSValue(newPromiseIn: context) { resolve, _ in
            resolve?.call(withArguments: [String(data: data, encoding: .utf8) ?? ""])
        }
    }

    static func json(data: Data) -> Any? {
        do {
            return try JSONSerialization.jsonObject(
                with: data, options: []
            )
        } catch {
            return nil
        }
    }

    static func createResponse(
        response: HTTPURLResponse,
        data: Data,
        context: JSContext
    ) -> [String: Any] {
        let jsonjs: @convention(block) () -> Any? = {
            FetchAPI.json(data: data)
        }
        let textjs: @convention(block) () -> Any? = {
            FetchAPI.text(data: data, context: context)
        }
        return [
            "url": response.url?.absoluteString,
            "ok": response.statusCode >= 200 && response.statusCode < 400,
            "status": response.statusCode,
            "json": JSValue(object: jsonjs, in: context) as Any,
            "text": JSValue(object: textjs, in: context) as Any
        ] as [String: Any]
    }

    public func registerAPIInto(context: JSContext) {
        let fetch: @convention(block) (JSValue, JSValue?) -> JSManagedValue? = { url, options in
            var fetchTask: Task<Void, Never>?
            let promise = JSValue(newPromiseIn: context) { [weak self] resolve, reject in
                guard let resolve, let reject else { return }
                guard let request = url.isInstance(of: Request.self) ? (url.toObjectOf(Request.self) as? Request)?.request : Request(url: url.toString(), options: options).request else {
                    print(url)
                    return
                }
                dump(request)
                guard let client = self?.client else { return }
                fetchTask = Task {
                    do {
                        let (data, response) = try await client.data(for: request)
                        guard let response = (response as? HTTPURLResponse) else {
                            reject.call(withArguments: ["URL is empty"])
                            return
                        }
                        resolve.call(withArguments: [
                            FetchAPI.createResponse(
                                response: response,
                                data: data,
                                context: context
                            )
                        ])
                    } catch let error {
                        reject.call(withArguments: [
                            [
                                "name": "FetchError",
                                "response": "\(error.localizedDescription)"
                            ]
                        ])
                        return
                    }
                }
                if let signal = options?.forProperty("signal").toType(AbortSignal.self) {
                    signal.onAbort = {
                        if signal.aborted {
                            fetchTask?.cancel()
                            reject.call(withArguments: [["name": "AbortError"]])
                        }
                    }
                }
            }

            return JSManagedValue(value: promise)
        }

        context.setObject(
            fetch,
            forKeyedSubscript: "fetch" as NSCopying & NSObjectProtocol
        )
    }
}
