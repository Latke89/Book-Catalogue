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
    func retrieveBookData()
    func retrieveAsync()
}

protocol HomeViewModelDelegate: AnyObject {
    func finishedLookingUpBook(book: GetISBNResponse?, error: Error?)
    func navigateToConfirmation(book: BookModel)
}

class HomeViewModel: HomeViewModelProtocol {
    
    private let apiClient: DummyJSONAPICleint
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    var bookRequestTask: URLSessionTask? = nil
    var coverTask: URLSessionTask? = nil
    var authorTask: URLSessionTask? = nil
    var book: GetISBNResponse?
    var isbn = ""
    weak var delegate: HomeViewModelDelegate?
    
    init(apiClient: DummyJSONAPICleint = DummyJSONAPICleint()) {
        self.apiClient = apiClient
    }
    
    
    func lookupBook(isbn: String, completion: @escaping (GetISBNResponse?, NetworkError?) -> ()) {
        let bookService = BookService(apiClient: apiClient)
        var networkError: NetworkError?
        self.isbn = isbn

        bookRequestTask = bookService.lookupByISBN(isbn: isbn) { [weak self] result in
            switch result {
            case .success(let response):
                self?.book = response
                completion(response, nil)
            case .failure(let error):
                networkError = error
                print(error)
                completion(nil, networkError)
            }
        }
        
        
    }
    
    func getBookDetails(isbn: String) {
        let coverService = CoverService(apiClient: CoverAPICleint())
        coverTask = coverService.lookupByISBN(isbn) { result in
            switch result {
            case .success(let response):
                print(response)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func asyncRetrieveBookData() async throws {
        do {
            let coverService = CoverService(apiClient: CoverAPICleint())
            let bookService = BookService(apiClient: DummyJSONAPICleint())
            var authorResponse: GetAuthorResponse?
            var workResponse: GetWorkResponse
            var cover: UIImage?
            guard let bookData = book else { return }
            
            cover = try await coverService.fetchCover(self.isbn)
            print("First call results: \(cover)")
            
            if bookData.authors == nil {
                workResponse = try await bookService.fetchWork(by: bookData.works[0].key)
                print("Reults of Fetch Work: \(workResponse)")
                authorResponse = try await bookService.fetchAuthor(workResponse.authors[0].author.key)
                print("Results of Fetch Author By Work: \(authorResponse)")
                
            } else {
                guard let authors = book?.authors else { return }
                
                authorResponse = try await bookService.fetchAuthor(authors[0].key)
            }
            
            await MainActor.run {
                guard let author = authorResponse, let cover = cover else { return }
                let book = BookModel(title: bookData.title,
                                 author: author.name,
                                 genre: [String](),
                                 image: cover,
                                 isbn: self.isbn,
                                 status: .toRead,
                                 owned: false,
                                 pageCount: bookData.number_of_pages ?? 0)
                self.delegate?.navigateToConfirmation(book: book)
            }
            
        } catch {
            print("An error occured: \(error)")
            throw error
        }
    }
    
    func retrieveAsync() {
        Task {
            try await asyncRetrieveBookData()
        }
    }
    
    func retrieveBookData() {
        
        let group = DispatchGroup()
        var cover: UIImage?
        var author: GetAuthorResponse?
        
        guard let bookData = book, let authors = bookData.authors else { return }
        let split = authors[0].key.components(separatedBy: "/")
        guard let olid = split.last else { return }
        
        let coverService = CoverService(apiClient: CoverAPICleint())
        let bookService = BookService(apiClient: DummyJSONAPICleint())

        group.enter()
        group.enter()
        activityIndicator.startAnimating()
        
        coverTask = coverService.lookupByISBN(self.isbn) { result in
            switch result {
            case .success(let response):
                cover = response
                print(response)
            case .failure(let error):
                print(error)
            }
            group.leave()
        }
        
        authorTask = bookService.lookupAuthor(olid: olid) { result in
            switch result {
            case .success(let response):
                author = response
            case .failure(let error):
                print(error)
            }
            group.leave()
        }
        
        group.notify(queue: .main) {
            self.activityIndicator.stopAnimating()
            guard let author = author, let cover = cover else { return }
            let book = BookModel(title: bookData.title,
                             author: author.name,
                             genre: [String](),
                             image: cover,
                             isbn: self.isbn,
                             status: .toRead,
                             owned: false,
                             pageCount: bookData.number_of_pages ?? 0)
            self.delegate?.navigateToConfirmation(book: book)
        }
        
    }
    
}
