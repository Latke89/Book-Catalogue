//
//  BaseNavigationController.swift
//  BookCatalogue
//
//  Created by Brett Gordon on 3/19/26.
//

import UIKit

class BaseNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithDefaultBackground()
//        navigationBarAppearance.backgroundImage = UIImage(named: "NavBarBg") // if wanna add bg image
        navigationBarAppearance.backgroundColor = .white // white bar color
        
        UINavigationBar.appearance().standardAppearance = navigationBarAppearance
        UINavigationBar.appearance().compactAppearance = navigationBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
        navigationBar.tintColor = .white
        navigationBar.isTranslucent = false
        
        self.modalPresentationStyle = .fullScreen
        
        print(self.view.frame)
    }
    
}
