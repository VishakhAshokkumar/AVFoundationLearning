//
//  NetworkManager.swift
//  AudioProcessing
//
//  Created by Vishak on 01/03/25.
//

import Foundation

class NetworkManager: NSObject {
    
    static let shared = NetworkManager()
    private static let apiKey = "272412df"
    private let baseUrl = "https://api.jamendo.com/v3.0/tracks/"
    
    private func fetch<T: Decodable>(from url: URL, completion: @escaping (Result<T, NetworkError>) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(.requestFailed(error)))
                return
            }
            
            guard let data = data else {
                completion(.failure(.invalidResponse))
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedResponse))
            } catch {
                completion(.failure(.decodingFailed(error)))
            }
        }
        task.resume() 
    }
    
    func fetchTracks(limit: Int = 10, completion: @escaping (Result<[Track], NetworkError>) -> Void) {
        var components = URLComponents(string: baseUrl) // ✅ Fixed `baseUrl` reference
        components?.queryItems = [
            URLQueryItem(name: "client_id", value: NetworkManager.apiKey),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "limit", value: "\(limit)")
        ]
        
        guard let url = components?.url else {
            completion(.failure(.invalidURL))
            return
        }
        
        
        fetch(from: url) { (result: Result<TrackResponse, NetworkError>) in
            switch result {
            case .success(let response):
                completion(.success(response.results))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
