//
//  Request.swift
//  
//
//  Created by Theodore Lampert on 15.05.23.
//

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
        self.form = nil
    }

    init(form: URLSearchParams) {
        self.json = nil
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
            self.json = nil
            self.form = value
        } else if let value = try? container.decode(String.self) {
            self.json = value
            self.form = nil
        }
        else {
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
