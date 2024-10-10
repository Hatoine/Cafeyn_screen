//
//  CatgoriesModel.swift
//  Cafeyn
//
//  Created by Antoine Antoiniol on 07/10/2024.
//

import Foundation

//Model object

struct Category: Decodable {
    let id: String
    let name: Name
    let subTopics: [Category]?
    let parentIDS: [String]?
}

struct Name: Codable, Equatable {
    let raw: String
    let key: String
}



