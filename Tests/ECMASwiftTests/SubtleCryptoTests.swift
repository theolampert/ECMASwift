import ECMASwift
import JavaScriptCore
import XCTest

final class SubtleCryptoTests: XCTestCase {
    let runtime = JSRuntime()

    func testDigestSHA256() {
        let result = runtime.context.evaluateScript("""
        const data = new Uint8Array([1, 2, 3, 4, 5])
        crypto.subtle.digest('SHA-256', Array.from(data))
        """)
        XCTAssertNotNil(result?.toArray())
    }

    func testEncryptAESGCM() {
        let result = runtime.context.evaluateScript("""
        const key = new Uint8Array(16).fill(1)
        const iv = new Uint8Array(16).fill(2)
        const data = new Uint8Array([1, 2, 3, 4, 5])
        crypto.subtle.encrypt('AES-GCM', Array.from(key), Array.from(iv), Array.from(data))
        """)
        XCTAssertNotNil(result?.toArray())
    }
}
