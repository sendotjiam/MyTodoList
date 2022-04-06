//
//  File.swift
//  MyTodoList
//
//  Created by Sendo Tjiam on 21/03/22.
//

import Foundation

enum Priority : Int{
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
}
