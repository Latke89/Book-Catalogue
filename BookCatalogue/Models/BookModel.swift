//
//  BookModel.swift
//  BookCatalogue
//
//  Created by Brett Gordon on 3/17/26.
//

import UIKit

struct BookModel {
    let title: String
    let author: String
    let genres: [String]
    let image: UIImage
    let isbn: String
    let status: Status
    let owned: Bool
    let pageCount: Int
}

enum Status {
    case read
    case toRead
    case dnf
}

//Page Count?

