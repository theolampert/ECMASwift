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
}
