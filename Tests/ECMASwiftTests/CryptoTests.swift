import Foundation
import ECMASwift
import JavaScriptCore
import XCTest

final class CryptoTests: XCTestCase {
    let runtime = JSRuntime()
    
    func testGetRandomValues() {
        let result = runtime.context.evaluateScript("""
        let array = new Uint32Array(10)
        let populatedArray = crypto.getRandomValues(array)
        populatedArray
        """)!
        XCTAssertTrue(result.toArray()!.allSatisfy { ($0 as! UInt) != 0 })
    }
    
    func testrandomUUID() {
        let result = runtime.context.evaluateScript("""
        crypto.randomUUID()
        """)!
        XCTAssertNotNil(UUID(uuidString: result.toString()))
    }
    
    func testGetRandomValuesZeroLength() {
        let result = runtime.context.evaluateScript("""
        let array = new Uint32Array(0)
        let populatedArray = crypto.getRandomValues(array)
        populatedArray.length
        """)!
        XCTAssertEqual(result.toInt32(), 0)
    }

    func testGetRandomValuesWithDifferentTypedArrays() {
        // Testing with a Uint8Array
        let resultUint8 = runtime.context.evaluateScript("""
        let array = new Uint8Array(10)
        let populatedArray = crypto.getRandomValues(array)
        populatedArray
        """)!
        XCTAssertTrue(resultUint8.toArray()!.allSatisfy { ($0 as! UInt) != 0 })
    }

    func testGetRandomValuesLargeArray() {
        let result = runtime.context.evaluateScript("""
        let array = new Uint32Array(1e5)  // An array with a large size
        let populatedArray = crypto.getRandomValues(array)
        populatedArray
        """)!
        XCTAssertTrue(result.toArray()!.allSatisfy { ($0 as! UInt) != 0 })
    }

    func testRandomUUIDFormat() {
        let result = runtime.context.evaluateScript("""
        crypto.randomUUID()
        """)!
        let uuid = result.toString()
        let uuidRegex = "^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$"
        XCTAssertTrue(NSPredicate(format: "SELF MATCHES %@", uuidRegex).evaluate(with: uuid))
    }

    func testRandomUUIDUniqueness() {
        let script = """
        let uuids = new Set();
        for (let i = 0; i < 1000; i++) {
            uuids.add(crypto.randomUUID());
        }
        uuids.size
        """
        let result = runtime.context.evaluateScript(script)!
        XCTAssertEqual(result.toInt32(), 1000)
    }
}
