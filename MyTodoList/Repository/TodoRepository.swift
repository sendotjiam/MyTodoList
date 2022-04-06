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
//        let items = getObject(forKey: "todos", castTo: [Todo].self) ?? nil
        let items = UserDefaults.standard.array(forKey: "todos") as? [Todo]
        print(items)
        return items
    }
    
    func addTodo(todo: Todo) {
        guard var items = self.getAllTodos() else { return }
        items.append(todo)
        print(items, todo)
        UserDefaults.standard.set(items, forKey: "todos")
//        setObject(items, forKey: "todos")
    }
}
