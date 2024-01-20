### ECMASwift

ECMASwift intends to implement a tiny subset of Browser APIs (mostly networking related) to make code sharing between iOS/macOS apps and web apps and the web easier.

In Javascript:
```js
// Define an async function to fetch some dummy data in Javascript
async function fetchProducts() {
    try {
        const res = await fetch("https://dummyjson.com/products/1")
        return await res.json()
    } catch(error) {
        console.log(error)
    }
}
```

In Swift:
```swift
import ECMASwift
import JavaScriptCore
import JSValueCoder

// (Optionally decode using JSValueCoder http://github.com/theolampert/JSValueCoder)
let decoder = JSValueDecoder()

// Initialise the runtime
let runtime = Runtime()

// Example model, we'll decode from the Javascript runtime, after it's been fetched from the example API.
struct Product {
    let discountPercentage: Double
    let rating: Double
    let category: String
    let id: Int
    let price: Int
    let title: String
    let stock: Int
    let thumbnail: String
    let brand: String
    let description: String
    let images: [String]
}

// Conform it to Codable
extension Product: Codable {}

// Load the javascript source file defined above, alternatively JS can be written inline.
let javascriptSource = try! String(contentsOfFile: "./example.js")

// Evaluate the script
_ = runtime.context.evaluateScript(javascriptSource)

// Call the `fetchProducts` function defined in the source file.
let result = try await runtime.context.callAsyncFunction(key: "fetchProducts")

// Decode using JSValueCoder
let product = try decoder.decode(Product.self, from: result)

// Print the result
print(product)
```
