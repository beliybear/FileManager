//
//  LoginViewController.swift
//  FileManager
//
//  Created by Beliy.Bear on 24.04.2023.
//

import UIKit

class LoginViewController: UIViewController {
    
    private let logoImage: UIImageView = {
        let logoImage = UIImageView()
        logoImage.image = UIImage(named: "Image")
        logoImage.translatesAutoresizingMaskIntoConstraints = false
        return logoImage
    }()
    
    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Введите пароль"
        textField.isSecureTextEntry = true
        textField.backgroundColor = .systemBackground
        textField.layer.cornerRadius = 8
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        textField.leftViewMode = .always
        textField.font = UIFont.systemFont(ofSize: 18)
        return textField
    }()
    
    private lazy var actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Создать пароль", for: .normal)
        button.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
        button.backgroundColor = UIColor.systemBlue
        button.layer.cornerRadius = 8
        button.setTitleColor(.systemBackground, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        return button
    }()
    
    private var isPasswordCreated: Bool = false
    private var isFirstPasswordInput: Bool = true
    private var firstPassword: String?
    
    private let keychainService: KeychainServiceProtocol = KeychainService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationController?.tabBarController?.tabBar.isHidden = true
        setupSubviews()
        setupConstraints()
        
        isPasswordCreated = keychainService.getData(forKey: "password") != nil
        actionButton.setTitle(isPasswordCreated ? "Продолжить" : "Создать пароль", for: .normal)
    }
    
    private func setupSubviews() {
        view.addSubview(passwordTextField)
        view.addSubview(actionButton)
        view.addSubview(logoImage)
    }
    
    func resetPassword() {
        if keychainService.deleteData(forKey: "password") {
            isPasswordCreated = false
            actionButton.setTitle("Создать пароль", for: .normal)
        } else {
            showAlert(title: "Ошибка", message: "Не удалось сбросить пароль")
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            logoImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            passwordTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            passwordTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            passwordTextField.widthAnchor.constraint(equalToConstant: 200),
            passwordTextField.heightAnchor.constraint(equalToConstant: 40),
            actionButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20),
            actionButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            actionButton.widthAnchor.constraint(equalToConstant: 200),
            actionButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    @objc private func actionButtonTapped() {
        guard let password = passwordTextField.text, !password.isEmpty, password.count >= 4 else {
            showAlert(title: "Ошибка", message: "Пароль должен содержать минимум 4 символа")
            return
        }
        
        if isPasswordCreated {
            if let savedPasswordData = keychainService.getData(forKey: "password"),
               let savedPassword = String(data: savedPasswordData, encoding: .utf8),
               savedPassword == password {
                openTabBarController()
            } else {
                showAlert(title: "Ошибка", message: "Неверный пароль")
            }
        } else {
            if isFirstPasswordInput {
                firstPassword = password
                passwordTextField.text = ""
                actionButton.setTitle("Повторите пароль", for: .normal)
                isFirstPasswordInput = false
            } else {
                if firstPassword == password {
                    if keychainService.saveData(password.data(using: .utf8)!, forKey: "password") {
                        openTabBarController()
                    } else {
                        showAlert(title: "Ошибка", message: "Не удалось сохранить пароль")
                    }
                } else {
                    showAlert(title: "Ошибка", message: "Пароли не совпадают")
                    passwordTextField.text = ""
                    actionButton.setTitle("Создать пароль", for: .normal)
                    isFirstPasswordInput = true
                }
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }
    
    private func openTabBarController() {
        let tabBarController = TabBarController()
        navigationController?.tabBarController?.tabBar.isHidden = false
        tabBarController.modalPresentationStyle = .fullScreen
        UIView.transition(with: self.view.window!, duration: 0.3, options: .transitionCrossDissolve, animations: {
            self.view.window?.rootViewController = tabBarController
        }, completion: nil)
    }
}
