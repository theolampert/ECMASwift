//
//  URLSearchParamsTests.swift
//
//
//  Created by Theodore Lampert on 08.06.23.
//

import ECMASwift
import JavaScriptCore
import XCTest

final class URLSearchParamsTests: XCTestCase {
    let runtime = ECMASwift()
    
//    func testInitialization() {
//        let result = runtime.context.evaluateScript("""
//        let params = new URLSearchParams("lang=swift&version=5.5")
//        params.getAll("lang")
//        """)!
//    }
    
    func testAppendingParams() {
        let result = runtime.context.evaluateScript("""
        let params = new URLSearchParams();
        params.append("q", "swift");
        params.append("version", "5.9");
        params.toString();
        """)!
        XCTAssertEqual(result.toString(), "q=swift&version=5.9")
    }
    
    func testSettingParams() {
        let result = runtime.context.evaluateScript("""
        let params = new URLSearchParams("q=swift");
        params.set("q", "rust");
        params.get("q")
        """)!
        XCTAssertEqual(result.toString(), "rust")
    }
    
    func testDeletingParams() {
        let result = runtime.context.evaluateScript("""
        let params = new URLSearchParams("q=swift&version=5.5");
        params.delete("q");
        params.toString();
        """)!
        XCTAssertEqual(result.toString(), "version=5.5")
    }
    
//    func testHasParam() {
//        let result = runtime.context.evaluateScript("""
//        let params = new URLSearchParams("q=swift&version=5.5");
//        params.has("q")
//        """)!
//        XCTAssertTrue(result.toBool())
//        
//        let result2 = runtime.context.evaluateScript("""
//        let params = new URLSearchParams("q=swift&version=5.5");
//        params.has("lang")
//        """)!
//        XCTAssertFalse(result2.toBool())
//    }
    
    func testMultipleValuesForSameKey() {
        let result = runtime.context.evaluateScript("""
        let params = new URLSearchParams("q=swift&q=rust&q=python");
        Array.from(params.getAll("q"))
        """)!
        let arrayResult = result.toArray() as! [String]
        XCTAssertEqual(arrayResult, ["swift", "rust", "python"])
    }
    
//    func testIteratingParams() {
//        let result = runtime.context.evaluateScript("""
//        let params = new URLSearchParams("q=swift&version=5.5");
//        let output = [];
//        for (let pair of params.entries()) {
//            output.push(pair);
//        }
//        output;
//        """)!
//        let arrayResult = result.toArray() as! [[String]]
//        XCTAssertEqual(arrayResult, [["q", "swift"], ["version", "5.5"]])
//    }
}

