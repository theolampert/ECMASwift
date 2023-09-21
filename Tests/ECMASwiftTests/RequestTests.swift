import ECMASwift
import JavaScriptCore
import JSValueCoder
import XCTest

final class RequestTests: XCTestCase {
    func testInitialiser() async throws {
        let runtime = ECMASwift()
        _ = runtime.context.evaluateScript("""
            let request = new Request("https://languagetool.org", { method: "get" })
        """)!

        XCTAssertEqual("https://languagetool.org", runtime.context.evaluateScript("request.url").toString())
        XCTAssertEqual("get", runtime.context.evaluateScript("request.method").toString())
    }
    
    func testURLSearchParamsBody() async throws {
        let runtime = ECMASwift()
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
}
