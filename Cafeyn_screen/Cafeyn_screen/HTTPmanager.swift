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
    case encodingFailed(Error)
    case noDataReceived(Error)
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
                Logger.success(message: LogType.success.logDescription)
                completion(.success(decodedData))
            } catch let decodingError {
                Logger.error(message: LogType.decodingError.logDescription + "\(decodingError.localizedDescription)")
                completion(.failure(.decodingFailed(decodingError)))
            }
        }.resume()
    }

    // Méthode générique pour envoyer une liste à une API sans retour de données
    func sendIdsListToAPI<T: Encodable>(list: [T], to urlString: String, completion: @escaping (Result<Void, APIError>) -> Void) {
        
        Logger.info(message: LogType.info.logDescription + "\(urlString)")
        
        guard let url = URL(string: urlString) else {
            Logger.error(message: LogType.error.logDescription + "\(urlString)")
            completion(.failure(.invalidURL))
            return
        }
        
        // 2. Créer la requête
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // 3. Encoder la liste en JSON
        do {
            let jsonData = try JSONEncoder().encode(list)
            request.httpBody = jsonData
        } catch {
            Logger.error(message: LogType.encodingError.logDescription)
            completion(.failure(.encodingFailed(error)))
            return
        }
        
        // 4. Envoyer la requête via URLSession
        let task = URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                Logger.error(message: LogType.requestError.logDescription + "\(error.localizedDescription)")
                completion(.failure(.requestFailed(error)))
                return
            }
            
            // Vérifier la réponse du serveur
            if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
                Logger.success(message: LogType.success.logDescription)
                completion(.success(())) // Succès sans retour de données
            } else {
                Logger.warning(message: LogType.warning.logDescription + "Réponse de l'API incorrecte")
                completion(.failure(.invalidResponse))
            }
        }
        
        // 5. Démarrer la tâche
        task.resume()
    }
}
  

