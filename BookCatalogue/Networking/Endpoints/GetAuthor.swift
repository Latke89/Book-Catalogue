//
//  GetAuthor.swift
//  BookCatalogue
//
//  Created by Brett Gordon on 3/16/26.
//

struct GetAuthorEndpoint: Endpoint {
    let olid: String
}

extension GetAuthorEndpoint {
    var path: String { "\(olid).json" }
    var method: HTTPMethod { .GET }
}
