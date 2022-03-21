//
//  AddTodoViewController.swift
//  MyTodoList
//
//  Created by Sendo Tjiam on 18/03/22.
//

import UIKit

class AddTodoViewController: UIViewController {
    
    // MARK: - Container
    private lazy var containerView : UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var dimmedAlpha : CGFloat = 0.6
    private lazy var dimmedView : UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = dimmedAlpha
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Height and Constraints
    var containerDefaultHeight: CGFloat = 0
    // Dynamic Container Constraint
    var containerViewHeightConstraint: NSLayoutConstraint?
    var containerViewBottomConstraint: NSLayoutConstraint?
    
    var dismissibleHeight: CGFloat = 0
    let maximumContainerHeight: CGFloat = UIScreen.main.bounds.height - 64
    // keep updated with new height
    var currentContainerHeight: CGFloat = 0
    
    // MARK: - UIKit
    private lazy var segmentedControl : UISegmentedControl = {
        let control = UISegmentedControl(items: ["Low", "Medium", "High"])
        control.selectedSegmentIndex = 0
        return control
    }()
    private lazy var textField : UITextField = {
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 48))
        textField.placeholder = "Enter todo here"
        textField.font = .systemFont(ofSize: 15)
        textField.borderStyle = .roundedRect
        textField.autocorrectionType = .no
        textField.keyboardType = .default
        textField.returnKeyType = .done
        textField.clearButtonMode = .whileEditing
        textField.contentVerticalAlignment = .center
        textField.delegate = self
        return textField
    }()
    private lazy var submitBtn : UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 64))
        button.backgroundColor = .systemPink
        button.layer.cornerRadius = 8
        button.setTitle("Add", for: .normal)
        button.addTarget(self, action: #selector(addNewTodo), for: .touchUpInside)
        return button
    }()
    private var stackView : UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupComponentHeight()
        setupUI()
        setupTapGesture()
        setupPanGesture()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateShowDimmedView()
        animatePresentContainer()
    }
}

// MARK: - UITextField Delegate
extension AddTodoViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}

// MARK: - Internal function
extension AddTodoViewController {
    private func setupComponentHeight() {
        containerDefaultHeight = view.frame.height * 3/4
        currentContainerHeight = view.frame.height * 3/4
        dismissibleHeight = view.frame.height * 1/2
    }
    private func setupUI() {
        view.backgroundColor = .clear
        view.addSubview(dimmedView)
        view.addSubview(containerView)
        setupStackView()
        setupConstraints()
    }
    private func setupStackView() {
        stackView = UIStackView(arrangedSubviews: [
            segmentedControl,
            textField,
            submitBtn
        ])
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 10
        
    }
    private func setupConstraints() {
        containerView.addSubview(stackView)
        NSLayoutConstraint.activate([
            dimmedView.topAnchor.constraint(equalTo: view.topAnchor),
            dimmedView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            dimmedView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimmedView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 32),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20)
        ])
        containerViewHeightConstraint = containerView.heightAnchor.constraint(equalToConstant: containerDefaultHeight)
        containerViewHeightConstraint?.isActive = true
        containerViewBottomConstraint = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: containerDefaultHeight)
        containerViewBottomConstraint?.isActive = true
    }
    private func animatePresentContainer() {
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.containerViewBottomConstraint?.constant = 0
            self?.view.layoutIfNeeded()
        }
    }
    private func animateShowDimmedView() {
        dimmedView.alpha = 0
        UIView.animate(withDuration: 0.4) { [weak self] in
            self?.dimmedView.alpha = self!.dimmedAlpha
        }
    }
    private func animateDismissView() {
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.containerViewBottomConstraint?.constant = self!.containerDefaultHeight
            self?.view.layoutIfNeeded()
        }
        dimmedView.alpha = dimmedAlpha
        UIView.animate(withDuration: 0.4) { [weak self] in
            self?.dimmedView.alpha = 0
        } completion: { [weak self] _ in
            self?.dismiss(animated: false)
        }
    }
    private func setupTapGesture() {
        let dismissGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleDismissGesture))
        dimmedView.addGestureRecognizer(dismissGesture)
    }
    private func setupPanGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(gesture:)))
        panGesture.delaysTouchesBegan = false
        panGesture.delaysTouchesEnded = false
        view.addGestureRecognizer(panGesture)
    }
    private func animateContainerHeight(_ height : CGFloat) {
        UIView.animate(withDuration: 0.4) { [weak self] in
            self?.containerViewHeightConstraint?.constant = height
            self?.view.layoutIfNeeded()
        }
        currentContainerHeight = height
    }
}

// MARK: - OBJC Action Function
extension AddTodoViewController {
    @objc private func addNewTodo() {
        guard let priority = Priority(rawValue: segmentedControl.selectedSegmentIndex),
              let title = textField.text else {
                  return
              }
        let todo = Todo(title: title, priority: priority)
        DispatchQueue.main.async { [weak self] in
            self?.animateDismissView()
        }
    }
    @objc private func handleDismissGesture() {
        animateDismissView()
    }
    @objc private func handlePanGesture(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        let isDraggingDown = translation.y > 0
        let newHeight = currentContainerHeight + (-translation.y)
        switch gesture.state {
        case .changed:
            if newHeight < maximumContainerHeight {
                containerViewHeightConstraint?.constant = newHeight
                view.layoutIfNeeded()
            }
        case .ended:
            if newHeight < dismissibleHeight {
                self.animateDismissView()
            } else if newHeight < containerDefaultHeight {
                animateContainerHeight(containerDefaultHeight)
            } else if newHeight < maximumContainerHeight && isDraggingDown {
                animateContainerHeight(containerDefaultHeight)
            } else if newHeight > containerDefaultHeight && !isDraggingDown {
                animateContainerHeight(maximumContainerHeight)
            }
        default:
            break
        }
    }
}
