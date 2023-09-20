import Foundation

enum HTTPMethod: String, Codable {
    case get
    case put
    case delete
    case post
}

struct Body: Codable {
    let json: String?
    let form: URLSearchParams?

    init(json: String) {
        self.json = json
        form = nil
    }

    init(form: URLSearchParams) {
        json = nil
        self.form = form
    }

    var value: Any? {
        if let json = json {
            return json
        } else if let form = form {
            return form
        }
        return nil
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let value = try? container.decode(URLSearchParams.self) {
            json = nil
            form = value
        } else if let value = try? container.decode(String.self) {
            json = value
            form = nil
        } else {
            throw DecodingError.typeMismatch(
                Body.self,
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Invalid property type"
                )
            )
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        if let json = json {
            try container.encode(json)
        } else if let form = form {
            try container.encode(form)
        } else {
            throw EncodingError.invalidValue(
                self,
                EncodingError.Context(
                    codingPath: encoder.codingPath,
                    debugDescription: "Invalid property value"
                )
            )
        }
    }
}

struct Request: Codable {
    let body: Body?
    let credentials: String?
    let method: HTTPMethod?
    let headers: [String: String]?
    let mode: String?
}
