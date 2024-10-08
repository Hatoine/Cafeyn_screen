//
//  ProtocolDataManger.swift
//  Cafeyn
//
//  Created by Antoine Antoiniol on 07/10/2024.
//

import Foundation

protocol ProtocolDataManger {
    func getCategories(apiUrl: String, completion: @escaping (Result<[Category], APIError>) -> Void)
}
