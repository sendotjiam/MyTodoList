//
//  File.swift
//  MyTodoList
//
//  Created by Sendo Tjiam on 21/03/22.
//

import Foundation

enum Priority : Int{
    case low
    case medium
    case high
}

struct Todo {
    let title : String
    let priority : Priority
}
