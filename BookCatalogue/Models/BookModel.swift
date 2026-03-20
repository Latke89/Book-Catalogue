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
    var genre: [String]
    let image: UIImage
    let isbn: String
    var status: Status
    var owned: Bool
    let pageCount: Int
}

enum Status: String {
    case read = "Read"
    case toRead = "To Read"
    case dnf = "Did Not Finish"
}
