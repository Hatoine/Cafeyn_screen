//
//  HTTPmanager.swift
//  Cafeyn
//
//  Created by Antoine Antoiniol on 07/10/2024.
//

import Foundation

//Possible errros while fetching data API
enum APIError: Error {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case decodingFailed(Error)
}

class HTTPmanager {
    
    //Generic methode to fetchData from API
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
                Logger.info(message: LogType.success.logDescription)
                completion(.success(decodedData))
            } catch let decodingError {
                Logger.error(message: LogType.decodingError.logDescription + "\(decodingError.localizedDescription)")
                completion(.failure(.decodingFailed(decodingError)))
            }
        }.resume()
    }
}
  

