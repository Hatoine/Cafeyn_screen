//
//  CategoriesViewModel.swift
//  Cafeyn
//
//  Created by Antoine Antoiniol on 07/10/2024.
//

import Foundation

class CategoriesViewModel: ObservableObject {
    
    // Propriétés observables
    @Published var categories: [Category]?
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    @Published var isErrorLoading: Bool = false
    private let apiUrl = "https://b2c-api.cafeyn.co/b2c/topics/signup?maxDepth=2"
    private var categoriesRepositories: ProtocolDataManger
    
    // Initialisation avec injection de dépendance
    init(categoriesRepositories: ProtocolDataManger) {
        self.categoriesRepositories = categoriesRepositories
    }
    
    // Méthode pour charger un utilisateur depuis le repository
    func fetchCategories() {
        self.isLoading = true
        categoriesRepositories.getCategories(apiUrl: apiUrl) { [weak self] result in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    switch result {
                case .success(let categories):
                        self?.isLoading = false
                    self?.categories = categories
                case .failure(let error):
                        self?.isLoading = false
                        self?.isErrorLoading = true
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
