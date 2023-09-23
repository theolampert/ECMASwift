import Foundation
import JavaScriptCore
import JSValueCoder

// https://developer.mozilla.org/en-US/docs/Web/API/Fetch_API

public class FetchAPI {
    let decoder = JSValueDecoder()

    private func text(data: Data) -> Any? {
        return String(data: data, encoding: .utf8)
    }

    private func json(data: Data) -> Any? {
        do {
            return try JSONSerialization.jsonObject(
                with: data, options: []
            )
        } catch {
            return nil
        }
    }

    private func createResponse(
        response: HTTPURLResponse,
        data: Data
    ) -> [String: Any] {
        let jsonjs: @convention(block) () -> Any? = {
            self.json(data: data)
        }
        let textjs: @convention(block) () -> Any? = {
            self.text(data: data)
        }
        return [
            "ok": true,
            "status": response.statusCode,
            "json": unsafeBitCast(jsonjs, to: JSValue.self),
            "text": unsafeBitCast(textjs, to: JSValue.self),
        ] as [String: Any]
    }

    private func createRequest(url: Foundation.URL, options: JSValue?) throws -> URLRequest? {
        var request = URLRequest(url: url)

        if let options {
            if let body = options.forProperty("body"), let body = try? Body.createFrom(body) {
                request.httpBody = body.data()
            }
            if let method = options.forProperty("method").toString() {
                request.httpMethod = method
            }
        }

        return request
    }

    public func registerAPIInto(context: JSContext) {
        let fetch: @convention(block) (String, JSValue?) -> JSValue? = { link, options in
            let promise = JSValue(newPromiseIn: context) { resolve, reject in
                guard let resolve, let reject else { return }
                Task {
                    do {
                        guard let url = Foundation.URL(string: link) else {
                            reject.call(withArguments: ["Invalid URL"])
                            return
                        }

                        guard let request = try self.createRequest(url: url, options: options) else {
                            reject.call(withArguments: ["Failed to create request"])
                            return
                        }
                        // Mark the request
                        let (data, response) = try await URLSession.shared.data(for: request)
                        guard let response = (response as? HTTPURLResponse) else {
                            reject.call(withArguments: ["URL is empty"])
                            return
                        }
                        resolve.call(withArguments: [
                            self.createResponse(
                                response: response,
                                data: data
                            ),
                        ])
                    } catch {
                        debugPrint(error)
                        reject.call(withArguments: [error])
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
