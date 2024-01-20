import Foundation

/// Protocol for `URLSession` to be able to inject mocked responses
public protocol HTTPClient: Sendable {
    func data(for: URLRequest) async throws -> (Data, URLResponse)
}

/// Conform URLSession to `HTTPClient` so we can pass it directly to the networking APIs (Fetch)
extension URLSession: HTTPClient {}

/// Mocking Helpers
public struct MockClient: HTTPClient {
    let data: Data
    let response: URLResponse

    public init(
        url: Foundation.URL,
        json: String,
        statusCode: Int
    ) {
        self.response = HTTPURLResponse(
            url: url,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: [:]
        )! as URLResponse
        self.data = json.data(using: .utf8)!
    }

    public func data(for: URLRequest) async throws -> (Data, URLResponse) {
        let randomMilliseconds = Int.random(in: 100...500)

        let nanoseconds = UInt64(randomMilliseconds) * 1_000_000
        try await Task.sleep(nanoseconds: nanoseconds)
        return (data, response)
    }
}
