//
//  MockHTTPManager.swift
//  Cafeyn_screen
//
//  Created by Antoine Antoiniol on 14/10/2024.
//


import Foundation
import XCTest
@testable import Cafeyn_screen // Replace with your actual module name

class MockHTTPManager: HTTPmanager {
    var shouldFail = false // Flag to simulate success or failure in API calls
    
    var mockData: Data?
     
     override func fetchData<T: Decodable>(from urlString: String, responseType: T.Type, completion: @escaping (Result<T, APIError>) -> Void) {
         if shouldFail {
             completion(.failure(.invalidResponse)) // Simulate error
         } else {
             if let data = mockData {
                 do {
                     let decodedData = try JSONDecoder().decode(T.self, from: data)
                     completion(.success(decodedData)) // Simulate successful response
                 } catch {
                     completion(.failure(.decodingFailed(error))) // Simulate decoding error
                 }
             } else {
                 completion(.failure(.noDataReceived(NSError(domain: "Test", code: 0, userInfo: nil)))) // Simulate no data
             }
         }
     }

    override func sendIdsListToAPI<T: Encodable>(list: [T], to urlString: String, completion: @escaping (Result<Void, APIError>) -> Void) {
        if shouldFail {
            completion(.failure(.requestFailed(NSError(domain: "", code: -1, userInfo: nil)))) // Simulate failure
        } else {
            completion(.success(())) // Simulate success
        }
    }
}
