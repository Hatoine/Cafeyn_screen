//
//  Untitled.swift
//  Cafeyn
//
//  Created by Antoine Antoiniol on 07/10/2024.
//

import Foundation

//Protocol for categories repository
protocol ProtocolCategoriesRepository {
    func getCategories(completion: @escaping (Result<[Category], APIError>) -> Void)
}

//Class to get data categories
final class CategoriesRepository: ProtocolCategoriesRepository {
    
    private var apiService: HTTPmanager
    private let apiUrl = "https://b2c-api.cafeyn.co/b2c/topics/signup?maxDepth=2"
    var categories: [Category] = []
    
    init(apiService: HTTPmanager) {
        self.apiService = apiService
    }
    
    //Get data categories 
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
