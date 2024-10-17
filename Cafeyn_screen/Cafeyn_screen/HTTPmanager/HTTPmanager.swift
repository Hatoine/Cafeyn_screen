//
//  HTTPmanager.swift
//  Cafeyn
//
//  Created by Antoine Antoiniol on 07/10/2024.
//

import Foundation

//Possible errros while fetching data API
enum APIError: Error, Equatable {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case decodingFailed(Error)
    case encodingFailed(Error)
    case noDataReceived(Error)
    
    static func == (lhs: APIError, rhs: APIError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL),
            (.invalidResponse, .invalidResponse):
            return true
        case (.noDataReceived, .noDataReceived),
            (.requestFailed, .requestFailed),
            (.decodingFailed, .decodingFailed),
            (.encodingFailed, .encodingFailed):
            return true
        default:
            return false
        }
    }
}

//Class for HTTP requests
class HTTPmanager {
    
    //Fetch data from API
    func fetchData<T: Decodable>(from urlString: String, responseType: T.Type, completion: @escaping (Result<T, APIError>) -> Void) {
        
        Logger.info(message: LogType.info.logDescription + "\(urlString)")
        
        guard let url = URL(string: urlString) else {
            Logger.error(message: LogType.error.logDescription + "\(urlString)")
            completion(.failure(.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                Logger.error(message: LogType.requestError.logDescription + "\(error.localizedDescription)")
                completion(.failure(.requestFailed(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
                Logger.warning(message: LogType.warning.logDescription + "\(String(describing: response))")
                completion(.failure(.invalidResponse))
                return
            }
            
            guard let data = data else {
                Logger.error(message: LogType.noData.logDescription)
                completion(.failure(.invalidResponse))
                return
            }
            
            do {
                let decodedData = try JSONDecoder().decode(T.self, from: data)
                Logger.success(message: LogType.success.logDescription)
                completion(.success(decodedData))
            } catch let decodingError {
                Logger.error(message: LogType.decodingError.logDescription + "\(decodingError.localizedDescription)")
                completion(.failure(.decodingFailed(decodingError)))
            }
        }.resume()
    }
    
    //Ssend data to API
    func sendIdsListToAPI<T: Encodable>(list: [T], to urlString: String, completion: @escaping (Result<Void, APIError>) -> Void) {
        
        Logger.info(message: LogType.info.logDescription + "\(urlString)")
        
        guard let url = URL(string: urlString) else {
            Logger.error(message: LogType.error.logDescription + "\(urlString)")
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONEncoder().encode(list)
            request.httpBody = jsonData
        } catch {
            Logger.error(message: LogType.encodingError.logDescription)
            completion(.failure(.encodingFailed(error)))
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                Logger.error(message: LogType.requestError.logDescription + "\(error.localizedDescription)")
                completion(.failure(.requestFailed(error)))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
                Logger.success(message: LogType.success.logDescription)
                completion(.success(()))
            } else {
                Logger.warning(message: LogType.warning.logDescription)
                completion(.failure(.invalidResponse))
            }
        }
        task.resume()
    }
}


