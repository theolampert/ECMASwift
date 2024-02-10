import JavaScriptCore
import os.lock

struct AsyncTimer: AsyncSequence {
    typealias Element = Void

    let interval: TimeInterval

    struct AsyncIterator: AsyncIteratorProtocol {
        let interval: TimeInterval

        init(interval: TimeInterval) {
            self.interval = interval
        }

        mutating func next() async -> Void? {
            guard !Task.isCancelled else { return () }
            do {
                try await Task.sleep(nanoseconds: UInt64(interval))
                return ()
            } catch {
                // Handle cancellation
                return nil
            }
        }
    }

    func makeAsyncIterator() -> AsyncIterator {
        return AsyncIterator(interval: interval)
    }
}


/// This implmenets several timer related browser APIs.`
///
/// References:
/// - [setTimeout()](https://developer.mozilla.org/en-US/docs/Web/API/setTimeout)
/// - [setInterval()](https://developer.mozilla.org/en-US/docs/Web/API/setInterval)
/// - [clearTimeout()](https://developer.mozilla.org/en-US/docs/Web/API/clearTimeout)
/// - [clearInterval()](https://developer.mozilla.org/en-US/docs/Web/API/clearInterval)
actor TimerAPI {
    private var timers = [String: Task<Void, Never>]()
    
    func createTimer(callback: JSValue, ms: Double, repeats: Bool) -> String {
        let timeInterval = ms * 1_000_000
        let uuid = UUID().uuidString
        
        if !repeats {
            timers[uuid] = Task.detached {
                try? await Task.sleep(nanoseconds: UInt64(timeInterval))
                if Task.isCancelled { return }
                callback.call(withArguments: [])
                await self.removeTimer(uuid: uuid)
            }
        } else {
            timers[uuid] = Task.detached {
                let timer = AsyncTimer(interval: timeInterval)
                for await _ in timer {
                    callback.call(withArguments: [])
                }
                await self.removeTimer(uuid: uuid)
            }
        }
        

        return uuid
    }
    
    func removeTimer(uuid: String) {
        timers[uuid]?.cancel()
        timers[uuid] = nil
    }
    
    func registerAPIInto(context: JSContext) {
        let setTimeout: @convention(block) (JSValue, Double) -> String = { callback, ms in
            self.createTimer(callback: callback, ms: ms, repeats: false)
        }
        let setInterval: @convention(block) (JSValue, Double) -> String = { callback, ms in
            self.createTimer(callback: callback, ms: ms, repeats: true)
        }
        let clearTimeout: @convention(block) (String) -> Void = { [weak self] timerId in
            Task { [self] in
                await self?.removeTimer(uuid: timerId)
            }
        }
        let clearInterval: @convention(block) (String) -> Void = { [weak self] timerId in
            Task { [self] in
                await self?.removeTimer(uuid: timerId)
            }
        }
        context.setObject(setTimeout, forKeyedSubscript: "setTimeout" as NSString)
        context.setObject(setInterval, forKeyedSubscript: "setInterval" as NSString)
        context.setObject(clearTimeout, forKeyedSubscript: "clearTimeout" as NSString)
        context.setObject(clearInterval, forKeyedSubscript: "clearInterval" as NSString)
    }
}
