import ECMASwift
import XCTest
import JavaScriptCore

final class BlobAPITests: XCTestCase {
    let runtime = ECMASwift()
    
    func testBlobCreation() {
        let expectedContent = "Hello, World!"
        
        let blob = runtime.context.evaluateScript("""
        Blob('\(expectedContent)');
        """)

        XCTAssertNotNil(blob, "Blob creation failed")
    }
    
    func testBlobTextMethod() async {
        let expectedContent = "Hello, World!"
        _ = runtime.context.evaluateScript("""
        async function getBlob() {
            let blob = new Blob(["\(expectedContent)"])
            return await blob.text()
        }
        """)
        let result = try! await runtime.context.callAsyncFunction(key: "getBlob")
        XCTAssertEqual(result.toString(), expectedContent)
    }
    
    func testBlobArrayBufferMethod() async {
        let expectedContent = "Hello, World!"
        _ = runtime.context.evaluateScript("""
        async function getBlob() {
            let blob = new Blob(["\(expectedContent)"])
            let res = await blob.arrayBuffer()
            return res
        }
        """)
        let result = try! await runtime.context.callAsyncFunction(key: "getBlob")
        XCTAssertEqual(result.forProperty("byteLength").toNumber(), 13)
    }
}
