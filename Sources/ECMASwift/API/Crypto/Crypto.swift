//
//  Crypto.swift
//  
//
//  Created by Theodore Lampert on 28.06.23.
//

import Foundation
import JavaScriptCore
import CommonCrypto

@objc protocol CryptoExports: JSExport {
    func getRandomValues(_ length: Int) -> [UInt8]
    func randomUUID() -> String
}

@objc class Crypto: NSObject, CryptoExports {
    func getRandomValues(_ length: Int) -> [UInt8] {
        var randomBytes = [UInt8](repeating: 0, count: length)
        let result = SecRandomCopyBytes(kSecRandomDefault, length, &randomBytes)
        
        if result == errSecSuccess {
            return randomBytes
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
        let cryptoClass: @convention(block) () -> Crypto = {
            Crypto()
        }
        context.setObject(
            unsafeBitCast(cryptoClass, to: AnyObject.self),
            forKeyedSubscript: "Crypto" as NSString
        )
    }
}
