//
//  Untitled.swift
//  Cafeyn
//
//  Created by Antoine Antoiniol on 07/10/2024.
//

import Foundation

// Implémentation du UserRepository qui fait appel au service API et (optionnellement) au service local
class CategoriesRepository: ProtocolDataManger {
    
    private var apiService: HTTPmanager
    
    init(apiService: HTTPmanager) {
        self.apiService = apiService
    }
    
    // Méthode pour récupérer un utilisateur depuis l'API ou une base locale
    func getCategories(apiUrl: String, completion: @escaping (Result<[Category], APIError>) -> Void) {
        apiService.fetchData(from: apiUrl, responseType: [Category].self) { result in
            switch result {
            case .success(let CategoriesModel):
                completion(.success(CategoriesModel))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
}
