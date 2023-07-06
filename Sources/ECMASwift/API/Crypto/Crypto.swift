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
    func getRandomBytes(_ length: Int) -> [UInt8]
}

@objc class Crypto: NSObject, CryptoExports {
    func getRandomBytes(_ length: Int) -> [UInt8] {
        var randomBytes = [UInt8](repeating: 0, count: length)
        let result = SecRandomCopyBytes(kSecRandomDefault, length, &randomBytes)
        
        if result == errSecSuccess {
            return randomBytes
        } else {
            return []
        }
    }
}

struct CryptoAPI {
    public func registerAPIInto(context: JSContext) {
        
    }
}
