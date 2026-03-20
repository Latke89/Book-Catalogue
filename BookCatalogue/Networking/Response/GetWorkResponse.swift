//
//  GetWorkResponse.swift
//  BookCatalogue
//
//  Created by Brett Gordon on 3/20/26.
//

import Foundation

struct GetWorkResponse: Codable {
    let authors: [WorkAuthorKey]
}

struct WorkAuthorKey: Codable {
    let author: AuthorKey
    let type: TypeKey
}

struct TypeKey: Codable {
    let key: String
}
