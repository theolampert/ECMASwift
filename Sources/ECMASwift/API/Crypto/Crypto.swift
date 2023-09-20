import Foundation
import JavaScriptCore
import CommonCrypto

@objc protocol CryptoExports: JSExport {
    func getRandomValues(_ array: [UInt32]) -> [UInt32]
    func randomUUID() -> String
}

@objc class Crypto: NSObject, CryptoExports {
    func getRandomValues(_ array: [UInt32]) -> [UInt32] {
        let size = array.count * MemoryLayout<UInt32>.size
        
        var buffer = [UInt8](repeating: 0, count: size)
        
        let result = SecRandomCopyBytes(kSecRandomDefault, size, &buffer)

        if result == errSecSuccess {
            return stride(from: 0, to: buffer.count, by: MemoryLayout<UInt32>.size).map { i in
                return buffer.withUnsafeBytes { ptr -> UInt32 in
                    let base = ptr.baseAddress!.assumingMemoryBound(to: UInt32.self)
                    return base[i / MemoryLayout<UInt32>.size]
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
