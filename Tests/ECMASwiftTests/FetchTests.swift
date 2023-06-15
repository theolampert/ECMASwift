import ECMASwift
import JavaScriptCore
import JSValueCoder
import XCTest

final class FetchTests: XCTestCase {
    func testGet() async throws {
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

        let expected = Product(
            discountPercentage: 12.96,
            rating: 4.69,
            category: "smartphones",
            id: 1,
            price: 549,
            title: "iPhone 9",
            stock: 94,
            thumbnail: "https://i.dummyjson.com/data/products/1/thumbnail.jpg",
            brand: "Apple",
            description: "An apple mobile which is nothing like apple",
            images: ["https://i.dummyjson.com/data/products/1/1.jpg",
                     "https://i.dummyjson.com/data/products/1/2.jpg",
                     "https://i.dummyjson.com/data/products/1/3.jpg",
                     "https://i.dummyjson.com/data/products/1/4.jpg",
                     "https://i.dummyjson.com/data/products/1/thumbnail.jpg"]
        )

        XCTAssertEqual(expected, product)
    }
}
