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
    var jwt: String? { get }
    
    func auth(with credentials: Credentials, completion: @escaping (Result<Void, NetworkError>) -> Void) -> URLSessionTask
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
    var jwt: String?
    func auth(with credentials: Credentials, completion: @escaping (Result<Void, NetworkError>) -> Void) -> URLSessionTask {
        var url = baseURL
        url.appendPathComponent("auth/login")
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.POST.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = try? JSONEncoder().encode(credentials)
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error {
                completion(.failure(.dataTaskError(error)))
                return
            }
            
            guard let data else {
                completion(.failure(.emptyData))
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
            
            guard let authResponse = try? JSONDecoder().decode(AuthResponse.self, from: data) else {
                completion(.failure(.decodingError("Failed to decode AuthResponse")))
                return
            }
            
            self?.jwt = authResponse.accessToken
            completion(.success(()))
        }
        
        task.resume()
        return task
    }
    
    func request(from endpoint: any Endpoint, completion: @escaping(Result<Data?, NetworkError>) -> Void) -> URLSessionTask {
        var url = baseURL
        url.appendPathComponent(endpoint.path)
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let jwt = jwt {
            request.setValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization")
        }
        
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
            
//            guard let authResponse = try? JSONDecoder().decode(AuthResponse.self, from: data) else {
//                completion(.failure(.decodingError("Failed to decode JSON")))
//                return
//            }
//            
//            self.jwt = authResponse.accessToken
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


struct AuthResponse: Codable {
    let id: Int
    let username: String
    let email: String
    let firstName: String
    let lastName: String
    let gender: String
    let image: String
    let accessToken: String
    let refreshToken: String
}

struct UserResponse: Codable {
    let id: Int
    let firstName: String
    let lastName: String
    let maidenName: String
    let age: Int
    let gender: String
    let email: String
    let phone: String
    let username: String
    let password: String
    let birthDate: String
    let image: String
    let bloodGroup: String
    let height: Double
    let weight: Double
    let eyeColor: String
}


protocol Endpoint {
    // The path for the endpoint. This is the part of the URL after the host of the API
    var path: String { get }
    // Headers to be sent in the request
    var headers: [String: String]? { get }
    // The HTTP method for this endpoint
    var method: HTTPMethod { get }
    // Parameters sent in the request body. It can't be used in `GET` requests
    var bodyParameters: [String: Any?]? { get }
    // Parameters sent in the URL.
    var queryParameters: [String: String]? { get }
}

extension Endpoint {
    var headers: [String : String]? {
        nil
    }
    var bodyParameters: [String: Any?]? {
        nil
    }
    var queryParameters: [String : String]? {
        nil
    }
}


// SPECIFIC ENDPOINT
struct GetCurrentUserEndpoint { }
extension GetCurrentUserEndpoint: Endpoint {
    var path: String { "/auth/me" }
    var method: HTTPMethod { .GET }
}

final class UserService: NetworkService {
    var apiClient: JWTAPIClient
    
    init(apiClient: JWTAPIClient = DummyJSONAPICleint()) {
        self.apiClient = apiClient
    }
}

extension UserService {
    func currentUser(completion: @escaping (Result<UserResponse, NetworkError>) -> Void) -> URLSessionTask {
        let endpoint = GetCurrentUserEndpoint()
        let task = apiClient.request(from: endpoint) { [weak self] result in
            switch result {
            case .success(let data):
                guard let self else {
                    completion(.failure(.systemError("Nil self in UserService.currentUser")))
                    return
                }
                
                guard let data else {
                    completion(.failure(.emptyData))
                    return
                }
                
                guard let userResponse = self.decodeUser(from: data) else {
                    completion(.failure(.decodingError("Failed to decode UserResponse")))
                    return
                }
                completion(.success(userResponse))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        return task
    }
    
    private func decodeUser(from data: Data) -> UserResponse? {
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(UserResponse.self, from: data)
        } catch {
            print("Failed to decode user: \(error)")
            return nil
        }
    }
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
//                guard let self else {
//                    completion(.failure(.systemError("Nil self in BookService.lookupByISBN")))
//                    return
//                }
                
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
