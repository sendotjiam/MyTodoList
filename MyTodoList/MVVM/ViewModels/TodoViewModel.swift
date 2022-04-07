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
    
    var todos : [Todo] {
        get { return TodoRepository.shared.getAllTodos() }
    }
    var todosRelay = BehaviorRelay<[Todo]>(value: [])
    var filteredTodos = [Todo]()
    var disposeBag = DisposeBag()

    var didFilteredTodos : (() -> Void)?
    var didSavedTodoToUserDefaults : ((Todo) -> Void)?
    
    func addNewTodo(with observable : Observable<Todo>, priorityIdx : Int) {
        observable.subscribe { [unowned self] todo in
            var existingTodos = todos
            guard let todo = todo.element else { return }
            existingTodos.append(todo)
            print(existingTodos.count)
            todosRelay.accept(existingTodos)
            
            let priority = Priority(rawValue: priorityIdx)
            filterTodos(by: priority)
            
            saveTodoToUserDefaults(with: todo)
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
    
    func saveTodoToUserDefaults(with todo : Todo) {
        TodoRepository.shared.saveTodo(todo: todo)
        didSavedTodoToUserDefaults?(todo)
    }
    
}
