//
//  File.swift
//  MyTodoList
//
//  Created by Sendo Tjiam on 21/03/22.
//

import Foundation

enum Priority : Int, Codable{
    case all
    case low
    case medium
    case high
}

struct Todo : Codable {
    let title : String
    let priority : Priority
     
    enum CodingKeys: String, CodingKey {
        case title, priority
    }

    init(title: String, priority: Priority) {
        self.title = title
        self.priority = priority
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        title = try values.decode(String.self, forKey: .title)
        print(title)
        priority = try values.decode(Priority.self, forKey: .priority)
        print(priority)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(priority.rawValue, forKey: .priority)
    }
}
