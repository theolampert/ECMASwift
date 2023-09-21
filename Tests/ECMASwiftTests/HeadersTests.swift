import ECMASwift
import JavaScriptCore
import JSValueCoder
import XCTest

final class HeadersTests: XCTestCase {
    func testGetAllHeaders() async throws {
        let runtime = ECMASwift()
        let result = runtime.context.evaluateScript("""
            try {
                let headers = new Headers()
                headers.setHeader("Content-Type", "application/json");
                headers.getAllHeaders()
            } catch(error) {
                error
            }
        """)!.toDictionary()!["Content-Type"] as? String

        XCTAssertEqual(result, "application/json")
    }

    func testGetHeader() async throws {
        let runtime = ECMASwift()
        let result = runtime.context.evaluateScript("""
            try {
                let headers = new Headers()
                headers.setHeader("Content-Type", "application/json");
                headers.getHeader("Content-Type")
            } catch(error) {
                error
            }
        """)!.toString()

        XCTAssertEqual(result, "application/json")
    }
}
