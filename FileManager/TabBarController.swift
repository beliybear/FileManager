//
//  TabBarController.swift
//  FileManager
//
//  Created by Beliy.Bear on 24.04.2023.
//

import UIKit

class TabBarController: UITabBarController {
    
    var firstTNC: UINavigationController!
    var secondTNC: UINavigationController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    private func setupUI() {
        firstTNC = UINavigationController.init(rootViewController: DocumentsViewController())
        secondTNC = UINavigationController.init(rootViewController: SettingsViewController())
        
        self.viewControllers = [firstTNC, secondTNC]
        
        let item1 = UITabBarItem(title: "Файлы",
                                 image: UIImage(systemName: "list.bullet"), tag: 0)
        let item2 = UITabBarItem(title: "Настройки",
                                 image: UIImage(systemName: "gearshape"), tag: 1)
        
        firstTNC.tabBarItem = item1
        secondTNC.tabBarItem = item2
        
        UITabBar.appearance().tintColor = .systemBlue
        UITabBar.appearance().backgroundColor = .systemGray6
    }
}
