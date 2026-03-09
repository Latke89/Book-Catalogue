//
//  GetISBNResponse.swift
//  BookCatalogue
//
//  Created by Brett Gordon on 3/9/26.
//

struct GetISBNResponse: Codable {
//    let publishers: [String]
    let number_of_pages: Int?
//    let covers: [Int]
    let key: String?
//    let authors: [AuthorKey]
//    let source_records: [String]
    let title: String
//    let identifiers: [Identifier]
//    let languages: [Language]
    let publish_date: String
//    let works: [Work]
//    let type: [Type]
    let first_sentence: String?
    let ocaid: String?
//    let isbn_10: [String]
//    let isbn_13: [String]
//    let lc_classifications: [String]
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
