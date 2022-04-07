//
//  TodoRepository.swift
//  MyTodoList
//
//  Created by Sendo Tjiam on 06/04/22.
//

import Foundation

class TodoRepository : BaseRepository {
    
    static let shared = TodoRepository()
    
    private override init() {}

    func getAllTodos() -> [Todo] {
        guard let items = getObject(forKey: "todos", castTo: [Todo].self)
        else { return [] }
        return items
    }
    
    func saveTodo(todo: Todo) {
        var items = self.getAllTodos()
        items.append(todo)
        setObject(items, forKey: "todos")
    }
    
    func clearRepository() {
        setObject([Todo](), forKey: "todos")
    }
}
