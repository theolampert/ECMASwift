import CommonCrypto
import JavaScriptCore

@objc protocol CryptoExports: JSExport {
    func getRandomValues(_ array: [UInt]) -> [UInt]
    func randomUUID() -> String

    var subtle: SubtleCryptoExports { get }
}

/// This implmenets the `Crypto` browser API.
///
/// Reference: [Crypto Reference on MDN](https://developer.mozilla.org/en-US/docs/Web/API/Crypto)
@objc final class Crypto: NSObject, CryptoExports {
    func getRandomValues(_ array: [UInt]) -> [UInt] {
        let size = array.count * MemoryLayout<UInt>.size

        var buffer = [UInt8](repeating: 0, count: size)

        let result = SecRandomCopyBytes(kSecRandomDefault, size, &buffer)

        if result == errSecSuccess {
            return stride(from: 0, to: buffer.count, by: MemoryLayout<UInt>.size).map { i in
                buffer.withUnsafeBytes { ptr -> UInt in
                    let base = ptr.baseAddress!.assumingMemoryBound(to: UInt.self)
                    return base[i / MemoryLayout<UInt>.size]
                }
            }
        } else {
            return []
        }
    }

    func randomUUID() -> String {
        return UUID().uuidString
    }

    lazy var subtle: SubtleCryptoExports = SubtleCrypto()
}

/// Helper to register the ``Crypto`` API with a context.
struct CryptoAPI {
    public func registerAPIInto(context: JSContext) {
        context.setObject(
            unsafeBitCast(Crypto(), to: AnyObject.self),
            forKeyedSubscript: "crypto" as NSString
        )
    }
}
