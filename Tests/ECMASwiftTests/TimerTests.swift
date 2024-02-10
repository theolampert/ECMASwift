import ECMASwift
import JavaScriptCore
import XCTest


final class TimerAPITests: XCTestCase {
    let runtime = JSRuntime()
    
    func testSetTimeout() {
        let expectation = self.expectation(description: "setTimeout should execute")
        
        let jsFunction: @convention(block) () -> Void = {
            expectation.fulfill()
        }
        runtime.context.setObject(unsafeBitCast(jsFunction, to: AnyObject.self), forKeyedSubscript: "jsFunction" as NSString)
        
        _ = runtime.context.evaluateScript("""
        setTimeout(jsFunction, 1000);
        """)
        
        waitForExpectations(timeout: 2.0, handler: nil)
    }
    
    func testClearTimeout() {
        let expectation = self.expectation(description: "setTimeout should not execute")
        expectation.isInverted = true
        
        let jsFunction: @convention(block) () -> Void = {
            expectation.fulfill()
        }
        runtime.context.setObject(unsafeBitCast(jsFunction, to: AnyObject.self), forKeyedSubscript: "jsFunction" as NSString)
        
        _ = runtime.context.evaluateScript("""
        var timerId = setTimeout(jsFunction, 50);
        clearTimeout(timerId);
        """)
        
        waitForExpectations(timeout: 2.0, handler: nil)
    }
    
    func testSetInterval() {
        let expectation = self.expectation(description: "setInterval should execute twice")
        expectation.expectedFulfillmentCount = 2

        let jsFunction: @convention(block) () -> Void = {
            expectation.fulfill()
        }
        runtime.context.setObject(unsafeBitCast(jsFunction, to: AnyObject.self), forKeyedSubscript: "jsFunction" as NSString)
        
        _ = runtime.context.evaluateScript("""
        var intervalId = setInterval(jsFunction, 50);
        setTimeout(() => { clearInterval(intervalId); }, 150);
        """)
        
        waitForExpectations(timeout: 2.0, handler: nil)
    }
    
    func testClearInterval() {
        let expectation = self.expectation(description: "setInterval should execute once")
        
        let jsFunction: @convention(block) () -> Void = {
            expectation.fulfill()
        }
        runtime.context.setObject(unsafeBitCast(jsFunction, to: AnyObject.self), forKeyedSubscript: "jsFunction" as NSString)
        
        _ = runtime.context.evaluateScript("""
        var intervalId = setInterval(jsFunction, 50);
        setTimeout(() => { clearInterval(intervalId); }, 75);
        """)
        
        waitForExpectations(timeout: 2.0, handler: nil)
    }
}
