//
//  CategoriesViewModel.swift
//  Cafeyn
//
//  Created by Antoine Antoiniol on 07/10/2024.
//

import Foundation

//Class to manage observable objects
final class CategoriesViewModel: ObservableObject {
    
    //Observable properties that automatically announce when changes occur
    @Published var categories: [Category]?
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    @Published var isErrorLoading: Bool = false
    @Published var isEmptyList: Bool = false
    
    private var categoriesRepositories: ProtocolCategoriesRepository
    private var interestsRepositories: ProtocolInterestsRepository
    
    
    init(categoriesRepositories: ProtocolCategoriesRepository, interestsRepositories: ProtocolInterestsRepository) {
        self.categoriesRepositories = categoriesRepositories
        self.interestsRepositories = interestsRepositories
    }
    
    //Fetch categories from webservice
    func fetchCategories() {
        self.isLoading = true
        categoriesRepositories.getCategories() { [weak self] result in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                switch result {
                case .success(let categories):
                    self?.isLoading = false
                    self?.categories = categories
                    if self?.categories?.isEmpty == true {
                        self?.isEmptyList = true
                    }
                case .failure(let error):
                    self?.isLoading = false
                    self?.isErrorLoading = true
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    //Send interests ids to webservice
    func saveSelectedCategories(ids: [String]) {
        interestsRepositories.saveCategoriesSelection(ids: ids) { result in
            switch result {
            case .success:
                Logger.success(message: LogType.successDataSent.logDescription)
            case .failure(let error):
                Logger.error(message: LogType.failureDataSent.logDescription + "\(error.localizedDescription)")
            }
        }
    }}
