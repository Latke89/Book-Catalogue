//
//  APICLient.swift
//  BookCatalogue
//
//  Created by Brett Gordon on 3/9/26.
//
import Foundation

protocol NetworkService {
    var apiClient: JWTAPIClient { get }
}

protocol JWTAPIClient {
    var baseURL: URL { get }
    
    func request(from endpoint: Endpoint, completion: @escaping (Result<Data?, NetworkError>) -> Void) -> URLSessionTask
}

struct Credentials: Codable {
    var username: String
    var password: String
}


final class DummyJSONAPICleint: JWTAPIClient {
    var baseURL: URL {
        URL(string: "https://openlibrary.org")!
    }
    
    func request(from endpoint: any Endpoint, completion: @escaping(Result<Data?, NetworkError>) -> Void) -> URLSessionTask {
        var url = baseURL
        url.appendPathComponent(endpoint.path)
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error {
                completion(.failure(.dataTaskError(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.systemError("Response is not an HTTPURLResponse")))
                return
            }
            
            guard 200..<299 ~= httpResponse.statusCode else {
                completion(.failure(.httpError(httpResponse.statusCode)))
                return
            }
            
            guard let data else {
                completion(.failure(.emptyData))
                return
            }
            
            completion(.success((data)))

        }
        
        task.resume()
        return task
    }
}


enum HTTPMethod: String {
    case GET
    case POST
    case DELETE
    case PUT
    case PATCH
}

enum NetworkError: Error {
    case dataTaskError(Error)
    case systemError(String)
    case emptyData
    case decodingError(String)
    case httpError(Int)
}


final class BookService: NetworkService {
    var apiClient: JWTAPIClient
    
    init(apiClient: JWTAPIClient = DummyJSONAPICleint()) {
        self.apiClient = apiClient
    }
}
extension BookService {
    func lookupByISBN(isbn: String, completion: @escaping (Result<GetISBNResponse, NetworkError>) -> Void) -> URLSessionTask {
        let endpoint = GetBookByISBNEndpoint(isbn: isbn)
        let task = apiClient.request(from: endpoint) { result in
        switch result {
            case .success(let data):
                
                guard let data else {
                    completion(.failure(.emptyData))
                    return
                }
                
                guard let userResponse = self.decodeBook(from: data) else {
                    completion(.failure(.decodingError("Failed to decode GetISBNResponse")))
                    return
                }
                completion(.success(userResponse))
            case .failure(let error):
                completion(.failure(error))
                }
            }
            return task
        }
    
    private func decodeBook(from data: Data) -> GetISBNResponse? {
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(GetISBNResponse.self, from: data)
        } catch {
            print("Failed to decode book: \(error)")
            return nil
        }
    }
}
