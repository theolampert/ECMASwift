### ECMASwift

ECMASwift intends to implement a tiny subset of Browser APIs (mostly networking related) to make code sharing between iOS/macOS apps and the web easier.

### Features

ECMASwift exposes the following browser APIs to JavascriptCore, some of these are incomplete, contributions welcome.

- Blob
- Console
- Crypto
- Fetch
- FormData
- Headers
- Request
- TextEncoder
- Timers
- URL
- URLSearchParams

### Examples

In Javascript:
```js
// Define an async function to fetch some dummy data in Javascript
async function fetchProducts() {
    try {
        const res = await fetch("https://google.com")
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

// Initialise the runtime
let runtime = JSRuntime()

// Load the javascript source file defined above, alternatively JS can be written inline.
let javascriptSource = try! String(contentsOfFile: "./example.js")

// Evaluate the script
_ = runtime.context.evaluateScript(javascriptSource)

// Call the `fetchProducts` function defined in the source file.
let result = try! await runtime.context.callAsyncFunction(key: "fetchProducts")

// Print the result
print(result.toString())
```
