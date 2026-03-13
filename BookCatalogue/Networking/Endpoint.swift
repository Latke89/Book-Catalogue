//
//  Endpoint.swift
//  BookCatalogue
//
//  Created by Brett Gordon on 3/13/26.
//

import Foundation

protocol Endpoint {
    // The path for the endpoint. This is the part of the URL after the host of the API
    var path: String { get }
    // Headers to be sent in the request
    var headers: [String: String]? { get }
    // The HTTP method for this endpoint
    var method: HTTPMethod { get }
    // Parameters sent in the request body. It can't be used in `GET` requests
    var bodyParameters: [String: Any?]? { get }
    // Parameters sent in the URL.
    var queryParameters: [String: String]? { get }
}

extension Endpoint {
    var headers: [String : String]? {
        nil
    }
    var bodyParameters: [String: Any?]? {
        nil
    }
    var queryParameters: [String : String]? {
        nil
    }
}
