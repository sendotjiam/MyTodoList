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
    var filteredTodos = [Todo]()
    
    private var viewModel : TodoViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        viewModel = TodoViewModel()
        bindViewModel()
        filteredTodos = viewModel.todos
    }

    @IBAction func priorityValueChanged(_ sender: UISegmentedControl) {
        let priority = Priority(rawValue: prioritySegmentedControl.selectedSegmentIndex)
        viewModel.filterTodos(by: priority)
    }
}

// MARK: - TableView Extension
extension TodoListViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredTodos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as UITableViewCell
        cell.textLabel?.text = self.filteredTodos[indexPath.row].title
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let alert = createCustomAlert(title: "Remove Todo", message: "Would you like to delete this todo? Once clear you can't see this todo anymore!")
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(
                UIAlertAction(title: "Confirm", style: .default) { [weak self] action in
                    self?.viewModel.deleteTodo(with: indexPath.row)
                }
            )
            present(alert, animated: true)
        }
    }
}

// MARK: - Business Logic Extension
extension TodoListViewController {
    private func bindViewModel() {
        viewModel.didFilteredTodos = { [weak self] in
            guard let todos = self?.viewModel.filteredTodos else { return }
            self?.filteredTodos = todos
            DispatchQueue.main.async {
                self?.updateTableView()
            }
        }
        
        viewModel.didClearTodos = { [weak self] in
            DispatchQueue.main.async {
                guard let alert = self?.createDefaultAlert(
                    title: "Remove Todo",
                    message: "You've successfully clear todos"
                )
                else { return }
                self?.present(alert, animated: true)
                self?.updateTableView()
            }
        }
        
        viewModel.didRemovedTodo = { [weak self] in
            DispatchQueue.main.async {
                guard let alert = self?.createDefaultAlert(
                    title: "Remove Todo",
                    message: "You've successfully removed todo"
                )
                else { return }
                self?.present(alert, animated: true)
                self?.updateTableView()
            }
        }
    }
    
    private func updateTableView() {
        let todos = self.viewModel.todos
        self.filteredTodos = todos
        self.tableView.reloadData()
    }
    
    
    @objc private func didTapAddBtn() {
        let priorityIdx = prioritySegmentedControl.selectedSegmentIndex
        DispatchQueue.main.async { [weak self] in
            let vc = AddTodoViewController()
            vc.modalPresentationStyle = .overCurrentContext
            self?.viewModel.addNewTodo(
                with: vc.todoSubjectObservable,
                priorityIdx: priorityIdx
            )
            self?.present(vc, animated: false, completion: nil)
        }
    }
    
    @objc private func didTapClearTodosBtn() {
        let alert = createCustomAlert(title: "Clear All Todos", message: "Would you like to clear your todos? Once deleted, there's nothing left on your todos!")
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(
            UIAlertAction(title: "Confirm", style: .default) { [weak self] action in
                self?.viewModel.clearRepository()
            }
        )
        present(alert, animated: true)
    }
}

// MARK: - Style UI Extension
extension TodoListViewController {
    private func setupUI() {
        navigationItem.title = "Todos"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem
            .rightBarButtonItem = UIBarButtonItem(
                title: "Clear",
                style: .plain,
                target: self,
                action: #selector(didTapClearTodosBtn)
            )
        view.backgroundColor = .systemBackground
        
        setupStackView()
        setupTableView()
        setupFloatingBtn()
        
        prioritySegmentedControl.addTarget(self, action: #selector(priorityValueChanged), for: .valueChanged)
    }
    
    private func setupStackView() {
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
    
    private func setupStackViewConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
        ])
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    private func setupFloatingBtn() {
        floatingButton.frame = CGRect(x: view.frame.width - 80, y: view.frame.height - 100, width: 50, height: 50)
        floatingButton.addTarget(self, action: #selector(didTapAddBtn), for: .touchUpInside)
        view.addSubview(floatingButton)
    }
}
