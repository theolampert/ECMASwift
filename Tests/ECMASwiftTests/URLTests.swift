import Foundation
import ECMASwift
import JavaScriptCore
import XCTest

final class URLTests: XCTestCase {
    let runtime = JSRuntime()
    
    func testPathname() {
        let result = runtime.context.evaluateScript("""
        let url = new URL("https://foobar.com/baz?1=2&3=4")
        url.pathname
        """)
        XCTAssertEqual(result!.toString(), "/baz")
    }
    
    func testGetProtocol() {
        let result = runtime.context.evaluateScript("""
        let url = new URL("https://foobar.com/baz?1=2&3=4")
        url.protocol
        """)
        XCTAssertEqual(result!.toString(), "https")
    }
    
    func testSetProtocol() {
        let result = runtime.context.evaluateScript("""
        let url = new URL("http://foobar.com/baz?1=2&3=4")
        url.protocol = "https"
        url.protocol
        """)
        XCTAssertEqual(result!.toString(), "https")
    }
    
    func testSearchParams() {
        let result = runtime.context.evaluateScript("""
        let url = new URL("https://foobar.com")
        url.searchParams.set("foo", "bar")
        url.searchParams.get("foo")
        """)
        XCTAssertEqual(result!.toString(), "bar")
    }
    
    func testToString() {
        let result = runtime.context.evaluateScript("""
        let url = new URL("https://foobar.com")
        url.searchParams.set("foo", "bar")
        url.toString()
        """)
        XCTAssertEqual(result!.toString(), "https://foobar.com?foo=bar")
    }
    
    func testOrigin() {
        let result = runtime.context.evaluateScript("""
        let url = new URL("https://foobar.com/baz?1=2&3=4")
        url.origin
        """)
        XCTAssertEqual(result!.toString(), "https://foobar.com")
    }

    func testHostname() {
        let result = runtime.context.evaluateScript("""
        let url = new URL("https://foobar.com/baz?1=2&3=4")
        url.hostname
        """)
        XCTAssertEqual(result!.toString(), "foobar.com")
    }

    func testPort() {
        let result = runtime.context.evaluateScript("""
        let url = new URL("https://foobar.com:8080/baz?1=2&3=4")
        url.port
        """)
        XCTAssertEqual(result!.toString(), "8080")
    }

    func testSetPort() {
        let result = runtime.context.evaluateScript("""
        let url = new URL("https://foobar.com/baz?1=2&3=4")
        url.port = "8080"
        url.port
        """)
        XCTAssertEqual(result!.toString(), "8080")
    }

    func testSearch() {
        let result = runtime.context.evaluateScript("""
        let url = new URL("https://foobar.com/baz?1=2&3=4")
        url.search
        """)
        XCTAssertEqual(result!.toString(), "?1=2&3=4")
    }

    func testSetHash() {
        let result = runtime.context.evaluateScript("""
        let url = new URL("https://foobar.com/baz?1=2&3=4")
        url.hash = "#section1"
        url.hash
        """)
        XCTAssertEqual(result!.toString(), "#section1")
    }

    func testURLWithoutProtocol() {
        let result = runtime.context.evaluateScript("""
        let url = new URL("foobar.com", "https://default.com")
        url.toString()
        """)
        XCTAssertEqual(result!.toString(), "https://default.com/foobar.com")
    }

    func testURLWithBaseURL() {
        let result = runtime.context.evaluateScript("""
        let base = new URL("https://base.com/directory/file")
        let url = new URL("another/file", base)
        url.toString()
        """)
        XCTAssertEqual(result!.toString(), "https://base.com/directory/another/file")
    }
}
