//
//  File.swift
//  
//
//  Created by Theodore Lampert on 15.06.23.
//

import Foundation
import JavaScriptCore

@objc protocol JSTimerExport : JSExport {
    func setTimeout(_ callback : JSValue,_ ms : Double) -> String
    func clearTimeout(_ identifier: String)
    func setInterval(_ callback : JSValue,_ ms : Double) -> String
}

@objc class JSTimer: NSObject, JSTimerExport {
    static let shared = JSTimer()
    
    var timers = [String: Timer]()
    
    let queue = DispatchQueue(label: "timers")

    static func registerInto(jsContext: JSContext) {
        jsContext.setObject(shared, forKeyedSubscript: "timerJS" as (NSCopying & NSObjectProtocol))
    }

    func clearTimeout(_ identifier: String) {
        queue.sync {
            let timer = timers.removeValue(forKey: identifier)
            timer?.invalidate()
        }
    }

    func setInterval(_ callback: JSValue,_ ms: Double) -> String {
        return createTimer(callback: callback, ms: ms, repeats: true)
    }

    func setTimeout(_ callback: JSValue, _ ms: Double) -> String {
        return createTimer(callback: callback, ms: ms , repeats: false)
    }

    func createTimer(callback: JSValue, ms: Double, repeats : Bool) -> String {
        let timeInterval = ms/1000.0
        let uuid = UUID().uuidString
        queue.sync {
            let timer = Timer.scheduledTimer(
                timeInterval: timeInterval,
                target: self,
                selector: #selector(self.callJsCallback),
                userInfo: callback,
                repeats: repeats
            )
            self.timers[uuid] = timer
        }
        return uuid
    }

    @objc func callJsCallback(_ timer: Timer) {
        queue.sync {
            let callback = (timer.userInfo as! JSValue)
            callback.call(withArguments: nil)
        }
    }
}
