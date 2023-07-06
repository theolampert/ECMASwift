//
//  URLTests.swift
//  
//
//  Created by Theodore Lampert on 26.06.23.
//

import Foundation
import ECMASwift
import JavaScriptCore
import XCTest

final class URLTests: XCTestCase {
    let runtime = ECMASwift()
    
    func testPathname() {
        let result = runtime.context.evaluateScript("""
        let url = new URL("https://foobar.com/baz?1=2&3=4")
        url.pathname
        """)
        XCTAssertEqual(result!.toString(), "/baz")
    }
    
    func testProtocol() {
        let result = runtime.context.evaluateScript("""
        let url = new URL("https://foobar.com/baz?1=2&3=4")
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
        url.searchParams.get("foo")
        url.toString()
        """)
        XCTAssertEqual(result!.toString(), "https://foobar.com?foo=bar")
    }
}
