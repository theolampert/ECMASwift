import ECMASwift
import JavaScriptCore
import JSValueCoder
import XCTest

final class RequestTests: XCTestCase {
    let runtime = JSRuntime()
    
    func testInitialiser() async throws {
        _ = runtime.context.evaluateScript("""
            let request = new Request("https://languagetool.org", { method: "get" })
        """)!

        XCTAssertEqual("https://languagetool.org", runtime.context.evaluateScript("request.url").toString())
        XCTAssertEqual("GET", runtime.context.evaluateScript("request.method").toString())
    }
    
    func testURLSearchParamsBody() async throws {
        let result = runtime.context.evaluateScript("""
            let params = new URLSearchParams("lang=swift&version=5.5")
            let request = new Request("https://languagetool.org", {
                    method: "post",
                    body: params
                }
            )
            request.text()
        """)!
        
        XCTAssertEqual("lang=swift&version=5.5", result.toString())
    }
    
    func testRequestMethod() {
        let result = runtime.context.evaluateScript("""
        let request = new Request("https://example.com", { method: "POST" });
        request.method;
        """)
        XCTAssertEqual(result!.toString(), "POST")
    }

    func testRequestURL() {
        let result = runtime.context.evaluateScript("""
        let request = new Request("https://example.com");
        request.url;
        """)
        XCTAssertEqual(result!.toString(), "https://example.com")
    }

    func testRequestHeaders() {
        let result = runtime.context.evaluateScript("""
        let request = new Request('https://example.com', {
            headers: {
                'Content-Type': 'application/json'
            }
        });
        request.headers.get('Content-Type');
        """)
        XCTAssertEqual(result!.toString(), "application/json")
    }
    
    func testRequestBodyString() {
        let result = runtime.context.evaluateScript("""
        let request = new Request('https://example.com', {
            method: 'POST',
            body: JSON.stringify({ key: 'value' })
        });
        request.text();
        """)
        XCTAssertEqual(result!.toString(), "{\"key\":\"value\"}")
    }
    
    func testBlobText() async {
        _ = runtime.context.evaluateScript("""
        async function getBlob() {
            let request = new Request('https://example.com', {
                method: 'POST',
                body: 'Blob Text'
            })
            let blob = await request.blob()
            return await blob.text()
        }
        """)
        let result = try! await runtime.context.callAsyncFunction(key: "getBlob")
        XCTAssertEqual(result.toString(), "Blob Text")
    }
    
    func testClone() {
        let result = runtime.context.evaluateScript("""
        let request = new Request("https://example.com", { method: "POST" });
        let cloned = request.clone()
        cloned.method
        """)
        XCTAssertEqual(result!.toString(), "POST")
    }
}
