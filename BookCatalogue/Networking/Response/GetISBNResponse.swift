//
//  GetISBNResponse.swift
//  BookCatalogue
//
//  Created by Brett Gordon on 3/9/26.
//

struct GetISBNResponse: Codable {
//    let publishers: [String]
    let number_of_pages: Int?
    let key: String?
    let authors: [AuthorKey]?
    let title: String
    let publish_date: String
    let works: [Work]
    let first_sentence: String?
    let ocaid: String?
    let latest_revision: Int?
    let revision: Int?
}

struct AuthorKey: Codable {
    let key: String
}
struct Identifier: Codable {
    let librarything: String
    let goodreads: String
}
struct Language: Codable {
    let key: String
}
struct Work: Codable {
    let key: String
}
struct Type: Codable {
    let key: String
}
