//
//  GetCover.swift
//  BookCatalogue
//
//  Created by Brett Gordon on 3/16/26.
//

struct GetCoverEndpoint: Endpoint {
    let isbn: String
}

extension GetCoverEndpoint {
    var path: String { "/b/isbn/\(isbn)-M.jpg" }
    var method: HTTPMethod { .GET }
}
