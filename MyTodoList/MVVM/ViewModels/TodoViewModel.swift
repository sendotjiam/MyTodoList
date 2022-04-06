//
//  TodoListViewModel.swift
//  MyTodoList
//
//  Created by Sendo Tjiam on 06/04/22.
//

import Foundation
import RxSwift
import RxCocoa

class TodoViewModel {
    
    var todos = [Todo]()
    var todosRelay = BehaviorRelay<[Todo]>(value: [])
    var filteredTodos = [Todo]()
    var disposeBag = DisposeBag()

//    init() {
//        guard let allTodos = TodoRepository.shared.getAllTodos()
//        else {return}
//        self.todosRelay.accept(allTodos)
//    }
    
    var didFilteredTodos : (() -> Void)?
    
    func addNewTodo(with observable : Observable<Todo>, priorityIdx : Int) {
        observable.subscribe { [unowned self] todo in
            // Get existing todo and store it to separate variable
            // then override the todolist
            var existingTodos = todosRelay.value
            guard let todo = todo.element
            else { return }
            existingTodos.append(todo)
            todosRelay.accept(existingTodos)
            let priority = Priority(rawValue: priorityIdx)
            filterTodos(by: priority)
        }.disposed(by: disposeBag)
    }
    
    func filterTodos(by priority : Priority?) {
        if priority == Priority.all {
            filteredTodos = todosRelay.value
        } else {
            todosRelay.map { todos in
                return todos.filter { $0.priority == priority }
            }.subscribe { [weak self] todos in
                self?.filteredTodos = todos
            }.disposed(by: disposeBag)
        }
        didFilteredTodos?()
    }
    
}
