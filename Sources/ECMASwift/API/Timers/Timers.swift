import JavaScriptCore
import os.lock

/// This implmenets several timer related browser APIs.`
///
/// References:
/// - [setTimeout()](https://developer.mozilla.org/en-US/docs/Web/API/setTimeout)
/// - [setInterval()](https://developer.mozilla.org/en-US/docs/Web/API/setInterval)
/// - [clearTimeout()](https://developer.mozilla.org/en-US/docs/Web/API/clearTimeout)
/// - [clearInterval()](https://developer.mozilla.org/en-US/docs/Web/API/clearInterval)
final class TimerAPI {
    var timers = [String: Timer]()

    private var lock = os_unfair_lock_s()

    func createTimer(callback: JSValue, ms: Double, repeats: Bool) -> String {
        let timeInterval = ms / 1000.0
        let uuid = UUID().uuidString
        let timer = Timer(timeInterval: timeInterval, repeats: repeats) { [weak self, weak callback] _ in
            if let callback = callback, callback.isObject {
                callback.call(withArguments: [])
            }

            if !repeats {
                os_unfair_lock_lock(&self!.lock)
                self?.timers[uuid] = nil
                os_unfair_lock_unlock(&self!.lock)
            }
        }

        os_unfair_lock_lock(&lock)
        timers[uuid] = timer
        os_unfair_lock_unlock(&lock)

        RunLoop.main.add(timer, forMode: .common)

        return uuid
    }

    func invalidateTimer(with id: String) {
        os_unfair_lock_lock(&lock)
        let timerInfo = timers.removeValue(forKey: id)
        os_unfair_lock_unlock(&lock)

        timerInfo?.invalidate()
    }

    func registerAPIInto(context: JSContext) {
        let setTimeout: @convention(block) (JSValue, Double) -> String = { callback, ms in
            self.createTimer(callback: callback, ms: ms, repeats: false)
        }
        let setInterval: @convention(block) (JSValue, Double) -> String = { callback, ms in
            self.createTimer(callback: callback, ms: ms, repeats: true)
        }
        let clearTimeout: @convention(block) (String) -> Void = { [weak self] timerId in
            self?.invalidateTimer(with: timerId)
        }
        let clearInterval: @convention(block) (String) -> Void = { [weak self] timerId in
            self?.invalidateTimer(with: timerId)
        }
        context.setObject(setTimeout, forKeyedSubscript: "setTimeout" as NSString)
        context.setObject(setInterval, forKeyedSubscript: "setInterval" as NSString)
        context.setObject(clearTimeout, forKeyedSubscript: "clearTimeout" as NSString)
        context.setObject(clearInterval, forKeyedSubscript: "clearInterval" as NSString)
    }
}
