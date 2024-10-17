//
//  InterestsRepository.swift
//  Cafeyn_screen
//
//  Created by Antoine Antoiniol on 14/10/2024.
//

import Foundation

//Protocol for interests repository
protocol ProtocolInterestsRepository {
    func saveCategoriesSelection(ids: [String], completion: @escaping (Result<Void, APIError>) -> Void)
}

//Class to manage user interests
final class InterestsRepository: ProtocolInterestsRepository {
    
    private let userDefaultsKey: String = "selectedInterests"
    var idsToSave: [String] = []
    private var apiService: HTTPmanager
    //Temporary empty url, awaiting backend infos
    private let url = ""
    
    init(apiService: HTTPmanager) {
        self.apiService = apiService
    }
    
    //Load interests from userDefaults
    func loadSelectedInterests() -> [Name] {
        if let data = UserDefaults.standard.object(forKey: userDefaultsKey) as? Data,
           let selectedInterests = try? JSONDecoder().decode([Name].self, from: data) {
            return selectedInterests
        }
        return []
    }
    
    //Save interests in userDefaults
    func saveSelectedInterests(_ interests: [Name]) {
        if let encoded = try? JSONEncoder().encode(interests) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    //Clear interests in userDefaults
    func clearSelectedInterests() {
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
    }
    
    //Send interests ids 
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
