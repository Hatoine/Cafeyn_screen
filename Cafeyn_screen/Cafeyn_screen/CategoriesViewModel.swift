//
//  CategoriesViewModel.swift
//  Cafeyn
//
//  Created by Antoine Antoiniol on 07/10/2024.
//

import Foundation

class CategoriesViewModel: ObservableObject {
    
    @Published var categories: [Category]?
    @Published var categoriesMap: [Name]?
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    @Published var isErrorLoading: Bool = false
    private let apiUrl = "https://b2c-api.cafeyn.co/b2c/topics/signup?maxDepth=2"
    private var categoriesRepositories: ProtocolDataManger
    
    init(categoriesRepositories: ProtocolDataManger) {
        self.categoriesRepositories = categoriesRepositories
    }
    
    func fetchCategories() {
        self.isLoading = true
        categoriesRepositories.getCategories(apiUrl: apiUrl) { [weak self] result in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    switch result {
                case .success(let categories):
                    self?.isLoading = false
                        self?.categories = categories
                        self?.categoriesMap = self?.extractNames(from: categories)
                case .failure(let error):
                        self?.isLoading = false
                        self?.isErrorLoading = true
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func extractKey(from categories: [Category]) -> [String] {
        var key: [String] = []
        
        for category in categories {
            key.append(category.id)
            
            for subTopic in category.subTopics ?? [] {
                key.append(subTopic.id)
            }
        }
        return key
    }
    
    func extractName(from categories: [Category]) -> [String] {
        var name: [String] = []
        
        for category in categories {
            name.append(category.name.raw)
            
            for subTopic in category.subTopics ?? [] {
                name.append(subTopic.name.raw)
            }
        }
        return name
    }
    
    func extractNames(from topics: [Category]) -> [Name] {
        var names: [Name] = []
        
        // Parcours chaque topic dans le tableau
        for topic in topics {
            // Ajouter le nom principal du topic
            names.append(topic.name)
            
            // Ajouter les noms des sous-thèmes du topic
            for subTopic in topic.subTopics ?? [] {
                names.append(subTopic.name)
            }
        }
        
        return names
    }
}
