//
//  ViewController.swift
//  MyTodoList
//
//  Created by Sendo Tjiam on 18/03/22.
//

import UIKit
import RxSwift
import RxCocoa

class TodoListViewController: UIViewController {
    
    // MARK: - UIKit
    private lazy var prioritySegmentedControl : UISegmentedControl = {
        let control = UISegmentedControl(items: ["All", "Low", "Medium", "High"])
        control.selectedSegmentIndex = 0
        return control
    }()
    private lazy var tableView : UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .systemBackground
        return tableView
    }()
    private var stackView : UIStackView!
    private lazy var floatingButton : UIButton = {
        let btnSize : CGFloat = 50
        let btn = UIButton(frame: CGRect(x: 0, y: 0, width: btnSize, height: btnSize))
        btn.backgroundColor = .systemPink
        let image = UIImage(
            systemName: "plus",
            withConfiguration: UIImage.SymbolConfiguration(
                pointSize: 28, weight: .medium)
        )
        btn.setImage(image, for: .normal)
        btn.tintColor = .white
        btn.layer.shadowRadius = 8
        btn.layer.shadowOpacity = 0.3
        btn.layer.cornerRadius = btnSize/2
        return btn
    }()
    
    // MARK: - TableView Data
    var todoList = BehaviorRelay<[Todo]>(value: [])
    var filteredTodos = [Todo]()
    
    // MARK: - RxSwift
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        floatingButton.frame = CGRect(x: view.frame.width - 80, y: view.frame.height - 100, width: 50, height: 50)
    }
}


extension TodoListViewController {
    func setupUI() {
        navigationItem.title = "Todo List"
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .systemBackground
        setupStackView()
        setupTableView()
        setupFloatingBtn()
    }
    
    func setupStackView() {
        stackView = UIStackView(arrangedSubviews: [prioritySegmentedControl, tableView])
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 8
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        stackView.isLayoutMarginsRelativeArrangement = true
        view.addSubview(stackView)
        setupStackViewConstraints()
    }
    
    func setupStackViewConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
        ])
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    func setupFloatingBtn() {
        floatingButton.addTarget(self, action: #selector(didTapAddBtn), for: .touchUpInside)
        view.addSubview(floatingButton)
    }
    
    func filterTodos(by priority: Priority?) {
        if priority == nil {
            self.filteredTodos = self.todoList.value
        } else {
            self.todoList.map { todos in
                return todos.filter { $0.priority == priority }
            }.subscribe { [weak self] todos in
                self?.filteredTodos = todos
            }.disposed(by: disposeBag)
        }
        updateTableView()
    }
    
    private func updateTableView() {
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    @objc func didTapAddBtn() {
        DispatchQueue.main.async {
            let vc = AddTodoViewController()
            vc.modalPresentationStyle = .overCurrentContext
            vc.todoSubjectObservable.subscribe { [weak self] todo in
                
                let priority = Priority(
                    rawValue: self?.prioritySegmentedControl.selectedSegmentIndex ?? 0 - 1
                )
                
                // Get existing todo and store it to separate variable
                // then override the todolist
                let existingTodos = self?.todoList.value
                guard let todo = todo.element,
                      var existingTodos = existingTodos
                else { return }
                existingTodos.append(todo)
                self?.todoList.accept(existingTodos)
                
                // Filter Todos
                self?.filterTodos(by: priority)
                
            }.disposed(by: self.disposeBag)
            self.present(vc, animated: false, completion: nil)
        }
    }
}

extension TodoListViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredTodos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as UITableViewCell
        cell.textLabel?.text = self.filteredTodos[indexPath.row].title
        return cell
    }
}