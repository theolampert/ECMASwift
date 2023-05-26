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

struct Request: Codable {
    let body: URLSearchParams?
    let credentials: String?
    let method: HTTPMethod?
    let mode: String?
}
