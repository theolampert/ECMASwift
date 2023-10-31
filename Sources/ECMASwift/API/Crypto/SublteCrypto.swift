import CommonCrypto
import JavaScriptCore

@objc protocol SubtleCryptoExports: JSExport {
    func digest(_ algorithm: String, _ data: [UInt8]) -> [UInt8]?
    func encrypt(_ algorithm: String, _ key: [UInt8], _ iv: [UInt8], _ data: [UInt8]) -> [UInt8]?
    func decrypt(_ algorithm: String, _ key: [UInt8], _ iv: [UInt8], _ data: [UInt8]) -> [UInt8]?
}

/// This implmenets the `SubtleCrypto` browser API.
///
/// Reference: [SubtleCrypto Reference on MDN](https://developer.mozilla.org/en-US/docs/Web/API/SubtleCrypto)
@objc final class SubtleCrypto: NSObject, SubtleCryptoExports {
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

        let cryptStatus = CCCrypt(
            CCOperation(kCCEncrypt),
            CCAlgorithm(kCCAlgorithmAES),
            CCOptions(kCCOptionPKCS7Padding),
            key,
            key.count,
            iv,
            data,
            data.count,
            &buffer,
            buffer.count,
            &numBytesEncrypted
        )

        if cryptStatus == kCCSuccess {
            return Array(buffer.prefix(numBytesEncrypted))
        }
        return nil
    }

    func decrypt(_ algorithm: String, _ key: [UInt8], _ iv: [UInt8], _ data: [UInt8]) -> [UInt8]? {
        guard algorithm == "AES-GCM", key.count == kCCKeySizeAES128 else { return nil }
        var buffer = [UInt8](repeating: 0, count: data.count + kCCBlockSizeAES128)
        var numBytesDecrypted: size_t = 0

        let cryptStatus = CCCrypt(
            CCOperation(kCCDecrypt),
            CCAlgorithm(kCCAlgorithmAES),
            CCOptions(kCCOptionPKCS7Padding),
            key,
            key.count,
            iv,
            data,
            data.count,
            &buffer,
            buffer.count,
            &numBytesDecrypted
        )

        if cryptStatus == kCCSuccess {
            return Array(buffer.prefix(numBytesDecrypted))
        }
        return nil
    }
}
