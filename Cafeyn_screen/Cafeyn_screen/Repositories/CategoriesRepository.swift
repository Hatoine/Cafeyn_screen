//
//  Untitled.swift
//  Cafeyn
//
//  Created by Antoine Antoiniol on 07/10/2024.
//

import Foundation

protocol ProtocolDataManager {
    func getCategories(completion: @escaping (Result<[Category], APIError>) -> Void)
}

// Implémentation du UserRepository qui fait appel au service API et (optionnellement) au service local
class CategoriesRepository: ProtocolDataManager {
    
    private var apiService: HTTPmanager
    private let apiUrl = "https://b2c-api.cafeyn.co/b2c/topics/signup?maxDepth=2"
    var categories: [Category] = []
    
    init(apiService: HTTPmanager) {
        self.apiService = apiService
    }
    
    // Méthode pour récupérer un utilisateur depuis l'API ou une base locale
    func getCategories(completion: @escaping (Result<[Category], APIError>) -> Void) {
        apiService.fetchData(from: apiUrl, responseType: [Category].self) { result in
            switch result {
            case .success(let CategoriesModel):
                self.categories = CategoriesModel
                completion(.success(CategoriesModel))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
}
