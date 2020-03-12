//
//  Person.swift
//  HallOfFame
//
//  Created by theevo on 3/11/20.
//  Copyright © 2020 theevo. All rights reserved.
//

import Foundation

struct Person: Codable {
    let firstName: String
    let lastName: String
    let cohort: String
    let id: Int?
    var likes: [Like]?
    var dislikes: [Dislike]?
    
    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case cohort
        case id = "person_id"
        case likes
        case dislikes
    }
}

extension Person: Equatable {
    static func == (lhs: Person, rhs: Person) -> Bool {
        lhs.firstName == rhs.firstName &&
            lhs.lastName == rhs.lastName &&
            lhs.cohort == rhs.cohort
    }
}

struct Like: Codable {
    let text: String
    
    enum CodingKeys: String, CodingKey {
        case text = "likes_text"
    }
}

struct Dislike: Codable {
    let text: String
    
    enum CodingKeys: String, CodingKey {
        case text = "dislikes_text"
    }
}

