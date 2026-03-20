//
//  ConfirmationViewModel.swift
//  BookCatalogue
//
//  Created by Brett Gordon on 3/19/26.
//

import Foundation

protocol ConfirmationViewModelProtocol {
    
}

class ConfirmationViewModel: ConfirmationViewModelProtocol {
    
    var book: BookModel
    
    init(book: BookModel) {
        self.book = book
    }
    
}
