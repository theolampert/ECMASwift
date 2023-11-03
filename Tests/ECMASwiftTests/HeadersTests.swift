import ECMASwift
import JavaScriptCore
import JSValueCoder
import XCTest

final class HeadersTests: XCTestCase {
    func testGetAllHeaders() async throws {
        let runtime = JSRuntime()
        let result = runtime.context.evaluateScript("""
            try {
                let headers = new Headers()
                headers.set("Content-Type", "application/json");
                headers.getAll()
            } catch(error) {
                error
            }
        """)!.toDictionary()!["Content-Type"] as? String

        XCTAssertEqual(result, "application/json")
    }

    func testGetHeader() async throws {
        let runtime = JSRuntime()
        let result = runtime.context.evaluateScript("""
            try {
                let headers = new Headers()
                headers.set("Content-Type", "application/json");
                headers.get("Content-Type")
            } catch(error) {
                error
            }
        """)!.toString()

        XCTAssertEqual(result, "application/json")
    }
}
