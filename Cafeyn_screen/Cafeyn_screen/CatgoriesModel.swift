//
//  CatgoriesModel.swift
//  Cafeyn
//
//  Created by Antoine Antoiniol on 07/10/2024.
//

import Foundation

//Model object

struct Category: Decodable, Hashable, Encodable {
    let id: String
    let name: Name
    let subTopics: [Category]?
}

struct Name: Codable, Hashable{
    let raw: String
    let key: String
}

