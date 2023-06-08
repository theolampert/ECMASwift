//
//  FetchAPI.swift
//  
//
//  Created by Theodore Lampert on 15.05.23.
//

import Foundation
import JavaScriptCore
import JSValueCoder

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
    
    func createResponse(
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
            "text": unsafeBitCast(textjs, to: JSValue.self)
        ] as [String: Any]
    }
    
    public func registerAPIInto(context: JSContext) {
        let fetch: @convention(block) (String, JSValue) -> JSValue? = { link, options in
            let promise = JSValue(newPromiseIn: context) { resolve, reject in
                if let url = URL(string: link) {
                    guard let requestOptions = try? self.decoder.decode(Request.self, from: options) else {
                        reject?.call(withArguments: ["Failed to parse request"])
                        return
                    }
                    
                    var request = URLRequest(url: url)
                    
                    if let method = requestOptions.method?.rawValue {
                        request.httpMethod = method
                    }

                    URLSession.shared.dataTask(with: request) { (data, response, error) in
                        if let error = error {
                            reject?.call(withArguments: [error])
                        } else if let data = data, let response = (response as? HTTPURLResponse) {
                            resolve?.call(withArguments: [
                                self.createResponse(
                                    response: response,
                                    data: data
                                )
                            ])
                        } else {
                            reject?.call(withArguments: ["URL is empty"])
                        }
                    }.resume()
                } else {
                    reject?.call(withArguments: ["Invalid URL"])
                }
            }
            
            return promise
        }

        context.setObject(fetch, forKeyedSubscript: "fetch" as NSCopying & NSObjectProtocol)
    }
}
