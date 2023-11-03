import Foundation
import ECMASwift
import JavaScriptCore
import XCTest

final class TextEncoderTests: XCTestCase {
    let runtime = JSRuntime()
    
    func testEncodingSimpleText() {
        let result = runtime.context.evaluateScript("""
        let encoder = new TextEncoder();
        let encoded = encoder.encode("Hello, World!");
        Array.from(encoded)
        """)!
        // The encoded value for "Hello, World!" in UTF-8 is:
        // [72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]
        XCTAssertEqual(result.toArray() as! [UInt8], [72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33])
    }
    
    func testEncodingNonAsciiText() {
        let result = runtime.context.evaluateScript("""
        let encoder = new TextEncoder();
        let encoded = encoder.encode("こんにちは");
        Array.from(encoded)
        """)!
        XCTAssertEqual(result.toArray() as! [UInt8], [227, 129, 147, 227, 130, 147, 227, 129, 171, 227, 129, 161, 227, 129, 175])
    }
    
    func testEncoderDefaultEncoding() {
        let result = runtime.context.evaluateScript("""
        let encoder = new TextEncoder();
        encoder.encoding
        """)!
        XCTAssertEqual(result.toString(), "utf-8")
    }
    
    func testEncodingEmptyText() {
        let result = runtime.context.evaluateScript("""
        let encoder = new TextEncoder();
        let encoded = encoder.encode("");
        Array.from(encoded)
        """)!
        XCTAssertEqual(result.toArray() as! [UInt8], [])
    }
    
    func testEncodingSpecialCharacters() {
        let result = runtime.context.evaluateScript("""
        let encoder = new TextEncoder();
        let encoded = encoder.encode("🚀 & ⚡️");
        Array.from(encoded)
        """)!
        XCTAssertEqual(result.toArray() as! [UInt8], [240, 159, 154, 128, 32, 38, 32, 226, 154, 161, 239, 184, 143])
    }
}
