//
//  InterestsRepository.swift
//  Cafeyn_screen
//
//  Created by Antoine Antoiniol on 14/10/2024.
//

import Foundation

protocol ProtocolDataInterestsManager {
    func saveCategoriesSelection(ids: [String], completion: @escaping (Result<Void, APIError>) -> Void)
}

class InterestsRepository: ProtocolDataInterestsManager {
        
    private let userDefaultsKey: String = "selectedInterests"
    var idsToSave: [String] = []
    private var apiService: HTTPmanager
    private let url = ""
    
    init(apiService: HTTPmanager) {
        self.apiService = apiService
    }
    
    // Charger les centres d'intérêt depuis UserDefaults
    func loadSelectedInterests() -> [Name] {
        if let data = UserDefaults.standard.object(forKey: userDefaultsKey) as? Data,
           let selectedInterests = try? JSONDecoder().decode([Name].self, from: data) {
            return selectedInterests
        }
        return []
    }
    
    // Sauvegarder les centres d'intérêts dans UserDefaults
    func saveSelectedInterests(_ interests: [Name]) {
        if let encoded = try? JSONEncoder().encode(interests) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    // Effacer tous les centres d'intérêt dans UserDefaults
    func clearSelectedInterests() {
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
    }
    
    func saveCategoriesSelection(ids: [String], completion: @escaping (Result<Void, APIError>) -> Void) {
            apiService.sendIdsListToAPI(list: ids, to: url) { result in
            self.idsToSave = ids
              switch result {
              case .success:
                  Logger.info(message: LogType.successDataSent.logDescription)
                  completion(.success(()))
              case .failure(let error):
                  Logger.error(message:  LogType.failureDataSent.logDescription + "\(error.localizedDescription)")
                  completion(.failure(.requestFailed(error)))
              }
          }
      }
}
