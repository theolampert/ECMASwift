import Foundation
import JavaScriptCore
import CommonCrypto

// https://developer.mozilla.org/en-US/docs/Web/API/Crypto

@objc protocol CryptoExports: JSExport {
    func getRandomValues(_ array: [UInt]) -> [UInt]
    func randomUUID() -> String
}

@objc class Crypto: NSObject, CryptoExports {
    func getRandomValues(_ array: [UInt]) -> [UInt] {
        let size = array.count * MemoryLayout<UInt>.size
        
        var buffer = [UInt8](repeating: 0, count: size)
        
        let result = SecRandomCopyBytes(kSecRandomDefault, size, &buffer)

        if result == errSecSuccess {
            return stride(from: 0, to: buffer.count, by: MemoryLayout<UInt>.size).map { i in
                return buffer.withUnsafeBytes { ptr -> UInt in
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
}

struct CryptoAPI {
    public func registerAPIInto(context: JSContext) {
        context.setObject(
            unsafeBitCast(Crypto(), to: AnyObject.self),
            forKeyedSubscript: "crypto" as NSString
        )
    }
}
