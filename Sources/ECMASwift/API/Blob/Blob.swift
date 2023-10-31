import Foundation
import JavaScriptCore

@objc 
protocol BlobExports: JSExport {
    func text() -> JSValue?
    func arrayBuffer() -> JSValue
}
 
/// This implmenets the `Blob` browser API.
///
/// Reference: [Blob Reference on MDN](https://developer.mozilla.org/en-US/docs/Web/API/Blob)
final class Blob: NSObject, BlobExports {
    var content: String

    weak var context: JSContext?

    init(content: String) {
        self.content = content
    }

    func text() -> JSValue? {
        guard let context = context else {
            fatalError("JSContext is nil")
        }

        return JSValue(newPromiseIn: context) { resolve, _ in
            let blobObject = JSValue(object: self.content, in: context)!
            resolve?.call(withArguments: [blobObject])
        }
    }

    func arrayBuffer() -> JSValue {
        return JSValue(newPromiseIn: context) { [weak self] resolve, reject in
            guard let data = self?.content.data(using: .utf8) else {
                let errorDescription = "Failed to convert blob content to ArrayBuffer"
                reject?.call(withArguments: [errorDescription])
                return
            }

            // Convert Data to [UInt8]
            let byteArray = [UInt8](data)

            // Convert [UInt8] to JavaScript ArrayBuffer
            let jsArrayBufferConstructor = self?.context?.evaluateScript("ArrayBuffer")
            let jsUint8ArrayConstructor = self?.context?.evaluateScript("Uint8Array")
            guard let arrayBuffer = jsArrayBufferConstructor?.construct(withArguments: [byteArray.count]),
                  let uint8Array = jsUint8ArrayConstructor?.construct(withArguments: [arrayBuffer])
            else {
                let errorDescription = "Failed to create ArrayBuffer"
                reject?.call(withArguments: [errorDescription])
                return
            }

            // Set bytes to ArrayBuffer
            for (index, byte) in byteArray.enumerated() {
                uint8Array.setValue(byte, at: index)
            }

            resolve?.call(withArguments: [arrayBuffer])
        }
    }
}

/// Helper to register the ``Blob`` API with a context.
struct BlobAPI {
    func registerAPIInto(context: JSContext) {
        let blobClass: @convention(block) (String) -> Blob = { text in
            let blob = Blob(content: text)
            blob.context = context
            return blob
        }

        context.setObject(
            unsafeBitCast(blobClass, to: AnyObject.self),
            forKeyedSubscript: "Blob" as NSString
        )
    }
}
