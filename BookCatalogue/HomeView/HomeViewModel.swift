//
//  HomeViewModel.swift
//  BookCatalogue
//
//  Created by Brett Gordon on 3/5/26.
//
import Foundation

protocol HomeViewModelProtocol {
    func lookupBook(isbn: String)
}

protocol HomeViewModelDelegate: AnyObject {
    func finishedLookingUpBook(book: GetISBNResponse?, error: Error?)
}

class HomeViewModel: HomeViewModelProtocol {
    
    private let apiClient: DummyJSONAPICleint
    var bookRequestTask: URLSessionTask? = nil
    var book: GetISBNResponse?
    weak var delegate: HomeViewModelDelegate?
    
    init(apiClient: DummyJSONAPICleint = DummyJSONAPICleint()) {
        self.apiClient = apiClient
    }
    
    
    func lookupBook(isbn: String) {
        let bookService = BookService(apiClient: apiClient)
        var networkError: NetworkError?
        
        bookRequestTask = bookService.lookupByISBN(isbn: isbn) { [weak self] result in
            switch result {
            case .success(let response):
                print(response)
                self?.book = response
            case .failure(let error):
                networkError = error
                print(error)
            }
        }
        DispatchQueue.main.async {
            self.delegate?.finishedLookingUpBook(book: self.book, error: networkError)
        }
    }
    
}
