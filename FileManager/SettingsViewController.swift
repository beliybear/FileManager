//
//  SettingsViewController.swift
//  FileManager
//
//  Created by Beliy.Bear on 24.04.2023.
//

import UIKit
import KeychainAccess

class SettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let settingsOptions = ["Сортировка", "Показывать размер фотографии", "Поменять пароль"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Settings"
        
        setupSubviews()
        setupConstraints()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        if UserDefaults.standard.object(forKey: "Сортировка") == nil {
            UserDefaults.standard.set(true, forKey: "Сортировка")
        }
    }
    
    private func setupSubviews() {
        view.addSubview(tableView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingsOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = settingsOptions[indexPath.row]
        
        if indexPath.row < 2 {
            let switchView = UISwitch()
            switchView.isOn = UserDefaults.standard.bool(forKey: settingsOptions[indexPath.row])
            switchView.tag = indexPath.row
            switchView.addTarget(self, action: #selector(switchValueChanged(_:)), for: .valueChanged)
            cell.accessoryView = switchView
        }
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 2 {
            let loginVC = LoginViewController()
            loginVC.resetPassword()
            loginVC.modalPresentationStyle = .fullScreen
            present(loginVC, animated: true)
        }
    }
    
    // MARK: - Actions
    
    @objc private func switchValueChanged(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: settingsOptions[sender.tag])
        NotificationCenter.default.post(name: .settingsDidChange, object: nil)
    }
}

extension Notification.Name {
    static let settingsDidChange = Notification.Name("settingsDidChange")
}
