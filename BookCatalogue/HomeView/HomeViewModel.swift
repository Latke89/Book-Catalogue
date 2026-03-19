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
    func retrieveBookData(isbn: String, bookData: GetISBNResponse)
}

protocol HomeViewModelDelegate: AnyObject {
    func finishedLookingUpBook(book: GetISBNResponse?, error: Error?)
}

class HomeViewModel: HomeViewModelProtocol {
    
    private let apiClient: DummyJSONAPICleint
    var bookRequestTask: URLSessionTask? = nil
    var coverTask: URLSessionTask? = nil
    var workTask: URLSessionTask? = nil
    var authorTask: URLSessionTask? = nil
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
    
    func getBookDetails(isbn: String) {
        let coverService = CoverService(apiClient: CoverAPICleint())

        coverTask = coverService.lookupByISBN(isbn) { [weak self] result in
            switch result {
            case .success(let response):
                print(response)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func retrieveBookData(isbn: String, bookData: GetISBNResponse) {
        
        let group = DispatchGroup()
        var cover: UIImage?
        var work: GetWorkResponse?
        var author: GetAuthorResponse?
        
        guard let authors = bookData.authors else { return }
        let split = authors[0].key.components(separatedBy: "/")
        guard let olid = split.last else { return }
        
        let coverService = CoverService(apiClient: CoverAPICleint())
        let bookService = BookService(apiClient: DummyJSONAPICleint())

//        group.enter()
        group.enter()
        group.enter()
        
        coverTask = coverService.lookupByISBN(isbn) { [weak self] result in
            switch result {
            case .success(let response):
                cover = response
                print(response)
            case .failure(let error):
                print(error)
            }
            group.leave()
        }
        
        authorTask = bookService.lookupAuthor(olid: olid) { [weak self] result in
            switch result {
            case .success(let response):
                author = response
            case .failure(let error):
                print(error)
            }
            group.leave()
        }
        
        group.notify(queue: .main) {
            guard let author = author, let cover = cover else { return }
            let book = BookModel(title: bookData.title,
                             author: author.name,
                             genres: [],
                             image: cover,
                             isbn: isbn,
                             status: .toRead,
                             owned: true,
                             pageCount: bookData.number_of_pages ?? 0)
            print(book)
        }
        
    }
    
}
