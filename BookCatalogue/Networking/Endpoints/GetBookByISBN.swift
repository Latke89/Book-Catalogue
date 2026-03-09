//
//  GetBookByISBN.swift
//  BookCatalogue
//
//  Created by Brett Gordon on 3/9/26.
//
struct GetBookByISBNEndpoint: Endpoint {
    let isbn: String
    
    var headers: [String : String] {
        ["accept" : "application/json"]
    }
}

extension GetBookByISBNEndpoint {
    var path: String { "/isbn/\(isbn).json" }
    var method: HTTPMethod { .GET }
}
