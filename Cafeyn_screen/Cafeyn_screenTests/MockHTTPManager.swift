//
//  MockHTTPManager.swift
//  Cafeyn_screen
//
//  Created by Antoine Antoiniol on 14/10/2024.
//


import Foundation
import XCTest
@testable import Cafeyn_screen

class MockHTTPManager: HTTPmanager {
    //Simulate success or failure in API calls
    var shouldFail = false
    
    var mockData: Data?
     
     override func fetchData<T: Decodable>(from urlString: String, responseType: T.Type, completion: @escaping (Result<T, APIError>) -> Void) {
         if shouldFail {
             completion(.failure(.invalidResponse)) // Simulate error
         } else {
             if let data = mockData {
                 do {
                     let decodedData = try JSONDecoder().decode(T.self, from: data)
                     // Simulate successful response
                     completion(.success(decodedData))
                 } catch {
                     // Simulate decoding error
                     completion(.failure(.decodingFailed(error)))
                 }
             } else {
                 // Simulate no data
                 completion(.failure(.noDataReceived(NSError(domain: "Test", code: 0, userInfo: nil))))
             }
         }
     }

    override func sendIdsListToAPI<T: Encodable>(list: [T], to urlString: String, completion: @escaping (Result<Void, APIError>) -> Void) {
        if shouldFail {
            // Simulate failure
            completion(.failure(.requestFailed(NSError(domain: "", code: -1, userInfo: nil))))
        } else {
            // Simulate success
            completion(.success(()))
        }
    }
}
