//
//  CatgoriesModel.swift
//  Cafeyn
//
//  Created by Antoine Antoiniol on 07/10/2024.
//

import Foundation

//Model object

struct Category: Decodable, Equatable, Hashable, Encodable {
    
    let id: String
    let name: Name
    let subTopics: [Category]?
    
}

struct Name: Codable, Equatable, Hashable{
    let raw: String
    let key: String
}

struct CategoryResponse: Decodable {
    let id: String
    let name: Name
}
