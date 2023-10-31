@preconcurrency import JavaScriptCore

/// This implmenets the `Fetch` browser API.
///
/// Reference: [Fetch API Reference on MDN](https://developer.mozilla.org/en-US/docs/Web/API/Fetch_API)
public final class FetchAPI {
    let session: URLSession
    
    public init(session: URLSession = URLSession.shared) {
        self.session = session
    }

    func text(data: Data) -> Any? {
        return String(data: data, encoding: .utf8)
    }

    func json(data: Data) -> Any? {
        do {
            return try JSONSerialization.jsonObject(
                with: data, options: []
            )
        } catch {
            return nil
        }
    }

    func createResponse(
        response: HTTPURLResponse,
        data: Data,
        context: JSContext
    ) -> [String: Any] {
        let jsonjs: @convention(block) () -> Any? = { [weak self] in
            self?.json(data: data)
        }
        let textjs: @convention(block) () -> Any? = { [weak self] in
            self?.text(data: data)
        }
        return [
            "ok": true,
            "status": response.statusCode,
            "json": JSValue(object: jsonjs, in: context) as Any,
            "text": JSValue(object: textjs, in: context) as Any,
        ] as [String: Any]
    }

    func createRequest(url: String, options: JSValue?) -> URLRequest? {
        return Request(url: url, options: options).request
    }
    
    public func registerAPIInto(context: JSContext) {
        let fetch: @convention(block) (String, JSValue?) -> JSValue? = { url, options in
            var fetchTask: Task<Void, Never>?
            let promise = JSValue(newPromiseIn: context) { resolve, reject in
                guard let resolve, let reject else { return }
                guard let request = self.createRequest(url: url, options: options) else {
                    reject.call(withArguments: ["Failed to create request"])
                    return
                }
                let session = self.session
                fetchTask = Task {
                    do {
                        let (data, response) = try await session.data(for: request)
                        guard let response = (response as? HTTPURLResponse) else {
                            reject.call(withArguments: ["URL is empty"])
                            return
                        }
                        resolve.call(withArguments: [
                            self.createResponse(
                                response: response,
                                data: data,
                                context: context
                            ),
                        ])
                    } catch {
                        reject.call(withArguments: ["\(error.localizedDescription)"])
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

            return promise
        }

        context.setObject(
            fetch,
            forKeyedSubscript: "fetch" as NSCopying & NSObjectProtocol
        )
    }
}
