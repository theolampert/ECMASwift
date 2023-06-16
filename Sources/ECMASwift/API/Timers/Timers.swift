//
//  TimerAPI.swift
//
//
//  Created by Theodore Lampert on 15.06.23.
//

import Foundation
import JavaScriptCore

class TimerAPI {
    var timers = [String: Timer]()

    let queue = DispatchQueue(label: "timers")

    func createTimer(callback: JSValue, ms: Double, repeats: Bool) -> String {
        let timeInterval = ms / 1000.0
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

    func registerIntoAPI(context: JSContext) {
        let setTimeout: @convention(block) (JSValue, Double) -> String = { callback, ms in
            self.createTimer(callback: callback, ms: ms, repeats: false)
        }
        let setInterval: @convention(block) (JSValue, Double) -> String = { callback, ms in
            self.createTimer(callback: callback, ms: ms, repeats: true)
        }
        let clearTimeout: @convention(block) (String) -> Void = { timerId in
            self.queue.sync {
                let timer = self.timers.removeValue(forKey: timerId)
                timer?.invalidate()
            }
        }

        let clearInterval: @convention(block) (String) -> Void = { timerId in
            self.queue.sync {
                let timer = self.timers.removeValue(forKey: timerId)
                timer?.invalidate()
            }
        }
        context.setObject(setTimeout, forKeyedSubscript: "setTimeout" as NSString)
        context.setObject(setInterval, forKeyedSubscript: "setInterval" as NSString)
        context.setObject(clearTimeout, forKeyedSubscript: "clearTimeout" as NSString)
        context.setObject(clearInterval, forKeyedSubscript: "clearInterval" as NSString)
    }
}
