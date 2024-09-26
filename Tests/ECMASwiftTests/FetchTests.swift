@testable import ECMASwift
import JavaScriptCore
import XCTest

final class FetchTests: XCTestCase {
    func testCreateURLRequest() async throws {
        let runtime = JSRuntime()
        
        let options: [String: Any] = [
            "method": ["POST", "GET", "PUT", "OPTIONS"].randomElement()!,
            "headers": [
                "Content-Type": "application/json"
            ],
            "body": "{\"foo\":\"bar\"}"
        ]
        
        let value = JSValue(object: options, in: runtime.context)
        let request = Request(url: "https://foobar.com", options: value).request
        
        XCTAssertEqual(request.url, URL(string: "https://foobar.com")!)
        XCTAssertEqual(request.httpMethod, options["method"] as? String)
        XCTAssertEqual(request.allHTTPHeaderFields, options["headers"] as? [String: String])
        XCTAssertEqual(String(data: request.httpBody!, encoding: .utf8), options["body"] as? String)
    }

    func testGetRequest() async {
        let client = MockClient(
            url: URL(string: "https://foobar.com")!,
            json: "{\"foo\": \"bar\"}",
            statusCode: 200
        )
        let runtime = JSRuntime(client: client)

        _ = runtime.context.evaluateScript("""
        async function getJSON() {
            let res = await fetch("https://foobar.com")
            let json = await res.text()
            return json
        }
        """)
        let result = try! await runtime.context.callAsyncFunction(key: "getJSON")

        XCTAssertEqual("{\"foo\": \"bar\"}", result.toString()!)
    }
    
    func testPostRequest() async {
        let client = MockClient(
            url: URL(string: "https://api.example.com/post")!,
            json: "{\"success\": true}",
            statusCode: 201
        )
        let runtime = JSRuntime(client: client)

        _ = runtime.context.evaluateScript("""
        async function postData() {
            let res = await fetch("https://api.example.com/post", {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({data: 'test'})
            })
            let json = await res.json()
            return json
        }
        """)
        let result = try! await runtime.context.callAsyncFunction(key: "postData")

        XCTAssertEqual(true, result.objectForKeyedSubscript("success").toBool())
    }
    
    func testFetchWithHeaders() async {
        let client = MockClient(
            url: URL(string: "https://api.example.com/headers")!,
            json: "{\"receivedHeader\": \"CustomValue\"}",
            statusCode: 200
        )
        let runtime = JSRuntime(client: client)

        _ = runtime.context.evaluateScript("""
        async function fetchWithHeaders() {
            let res = await fetch("https://api.example.com/headers", {
                headers: {
                    'X-Custom-Header': 'CustomValue'
                }
            })
            let json = await res.json()
            return json
        }
        """)
        let result = try! await runtime.context.callAsyncFunction(key: "fetchWithHeaders")

        XCTAssertEqual("CustomValue", result.objectForKeyedSubscript("receivedHeader").toString())
    }
    
    func testFetchError() async {
        let client = MockClient(
            url: URL(string: "https://api.example.com/error")!,
            json: "{\"error\": \"Not Found\"}",
            statusCode: 404
        )
        let runtime = JSRuntime(client: client)

        _ = runtime.context.evaluateScript("""
        async function fetchWithError() {
            try {
                let res = await fetch("https://api.example.com/error")
                if (!res.ok) {
                    throw new Error(`HTTP error! status: ${res.status}`)
                }
                return await res.json()
            } catch (e) {
                return e.message
            }
        }
        """)
        let result = try! await runtime.context.callAsyncFunction(key: "fetchWithError")

        XCTAssertEqual("HTTP error! status: 404", result.toString())
    }
}
