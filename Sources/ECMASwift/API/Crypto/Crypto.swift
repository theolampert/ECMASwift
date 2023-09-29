import Foundation
import JavaScriptCore
import CommonCrypto

// https://developer.mozilla.org/en-US/docs/Web/API/Crypto

@objc protocol SubtleCryptoExports: JSExport {
    func digest(_ algorithm: String, _ data: [UInt8]) -> [UInt8]?
    func encrypt(_ algorithm: String, _ key: [UInt8], _ iv: [UInt8], _ data: [UInt8]) -> [UInt8]?
    func decrypt(_ algorithm: String, _ key: [UInt8], _ iv: [UInt8], _ data: [UInt8]) -> [UInt8]?
}

@objc class SubtleCrypto: NSObject, SubtleCryptoExports {
    func digest(_ algorithm: String, _ data: [UInt8]) -> [UInt8]? {
        guard algorithm == "SHA-256" else { return nil }
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        _ = data.withUnsafeBytes {
            CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
        }
        return hash
    }
    
    func encrypt(_ algorithm: String, _ key: [UInt8], _ iv: [UInt8], _ data: [UInt8]) -> [UInt8]? {
        guard algorithm == "AES-GCM", key.count == kCCKeySizeAES128 else { return nil }
        var buffer = [UInt8](repeating: 0, count: data.count + kCCBlockSizeAES128)
        var numBytesEncrypted: size_t = 0
        
        let cryptStatus = CCCrypt(CCOperation(kCCEncrypt),
                                  CCAlgorithm(kCCAlgorithmAES),
                                  CCOptions(kCCOptionPKCS7Padding),
                                  key, key.count,
                                  iv,
                                  data, data.count,
                                  &buffer, buffer.count,
                                  &numBytesEncrypted)
        
        if cryptStatus == kCCSuccess {
            return Array(buffer.prefix(numBytesEncrypted))
        }
        return nil
    }
    
    func decrypt(_ algorithm: String, _ key: [UInt8], _ iv: [UInt8], _ data: [UInt8]) -> [UInt8]? {
        guard algorithm == "AES-GCM", key.count == kCCKeySizeAES128 else { return nil }
        var buffer = [UInt8](repeating: 0, count: data.count + kCCBlockSizeAES128)
        var numBytesDecrypted: size_t = 0
        
        let cryptStatus = CCCrypt(CCOperation(kCCDecrypt),
                                  CCAlgorithm(kCCAlgorithmAES),
                                  CCOptions(kCCOptionPKCS7Padding),
                                  key, key.count,
                                  iv,
                                  data, data.count,
                                  &buffer, buffer.count,
                                  &numBytesDecrypted)
        
        if cryptStatus == kCCSuccess {
            return Array(buffer.prefix(numBytesDecrypted))
        }
        return nil
    }
}


@objc protocol CryptoExports: JSExport {
    func getRandomValues(_ array: [UInt]) -> [UInt]
    func randomUUID() -> String
    
    var subtle: SubtleCryptoExports { get }
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
    
    lazy var subtle: SubtleCryptoExports = SubtleCrypto()
}

struct CryptoAPI {
    public func registerAPIInto(context: JSContext) {
        context.setObject(
            unsafeBitCast(Crypto(), to: AnyObject.self),
            forKeyedSubscript: "crypto" as NSString
        )
    }
}
