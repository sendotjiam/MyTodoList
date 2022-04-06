//
//  TodoRepository.swift
//  MyTodoList
//
//  Created by Sendo Tjiam on 06/04/22.
//

import Foundation

class TodoRepository : BaseRepository {
    
    static let shared = TodoRepository()

    func getAllTodos() -> [Todo]? {
        let items = getObject(forKey: "todos", castTo: [Todo].self) ?? nil
        return items
    }
    
    func addTodo(todo: Todo) {
        guard var items = self.getAllTodos() else { return }
        items.append(todo)
        setObject(items, forKey: "todos")
    }
}
