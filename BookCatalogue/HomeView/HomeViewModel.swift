//
//  HomeViewModel.swift
//  BookCatalogue
//
//  Created by Brett Gordon on 3/5/26.
//
import Foundation
import UIKit

protocol HomeViewModelProtocol {
    func lookupBook(isbn: String, completion: @escaping(GetISBNResponse?, NetworkError?) -> ())
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
    
    
    func lookupBook(isbn: String, completion: @escaping (GetISBNResponse?, NetworkError?) -> ()) {
        let bookService = BookService(apiClient: apiClient)
        let activityIndicator = UIActivityIndicatorView()
        var networkError: NetworkError?
        
//        activityIndicator.startAnimating()
        bookRequestTask = bookService.lookupByISBN(isbn: isbn) { [weak self] result in
//            activityIndicator.stopAnimating()
            switch result {
            case .success(let response):
                print("Your book is ----- \(response)")
                self?.book = response
                completion(response, nil)
            case .failure(let error):
                networkError = error
                print(error)
                completion(nil, error)
            }
        }
    }
    
}
