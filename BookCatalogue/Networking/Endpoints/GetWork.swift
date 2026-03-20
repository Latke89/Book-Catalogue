//
//  GetWork.swift
//  BookCatalogue
//
//  Created by Brett Gordon on 3/20/26.
//

import Foundation

struct GetWork: Endpoint {
    let olid: String
}
extension GetWork {
    var path: String {"\(olid).json"}
    var method: HTTPMethod { .GET }
}
