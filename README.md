### ECMASwift

ECMASwift intends to implement a tiny subset of Javascript APIs (mostly networking related) to make code sharing between iOS/macOS apps and the web easier.


```swift
import ECMASwift
import JavaScriptCore
import JSValueCoder

struct Product: Codable, Equatable {
    let discountPercentage, rating: Double
    let category: String
    let id, price: Int
    let title: String
    let stock: Int
    let thumbnail: String
    let brand, description: String
    let images: [String]
}

let decoder = JSValueDecoder()
let runtime = ECMASwift()
_ = runtime.context.evaluateScript("""
    async function fetchProducts() {
        try {
            const res = await fetch("https://dummyjson.com/products/1")
            return await res.json()
        } catch(error) {
            console.log(error)
        }
    }
""")
let result = try await runtime.context.callAsyncFunction(key: "fetchProducts")
let product = try decoder.decode(Product.self, from: result)
print(product)
```
