import Foundation
import ECMASwift
import JavaScriptCore
import XCTest

final class CryptoTests: XCTestCase {
    let runtime = ECMASwift()
    
    func testGetRandomValues() {
        let result = runtime.context.evaluateScript("""
        let array = new Uint32Array(10)
        let populatedArray = crypto.getRandomValues(array)
        populatedArray
        """)!
        XCTAssertTrue(result.toArray()!.allSatisfy { ($0 as! UInt32) != 0 })
    }
    
    func testrandomUUID() {
        let result = runtime.context.evaluateScript("""
        crypto.randomUUID()
        """)!
        XCTAssertNotNil(UUID(uuidString: result.toString()))
    }
}
