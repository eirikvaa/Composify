//
//  AppDelegate.swift
//  Composify
//
//  Created by Eirik Vale Aase on 17.07.2016.
//  Copyright © 2016 Eirik Vale Aase. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        registerFoundationStoreObjectIfNeeded()
        registerNavigationBarAppearance()
        registerPageControlAppearance()
        
        return true
    }
}

private extension AppDelegate {
    func registerFoundationStoreObjectIfNeeded() {
        let userDefaults = UserDefaults.standard
        if userDefaults.value(forKey: Strings.UserDefaults.projectStoreID) as? String == nil {
            var defaultService = DatabaseServiceFactory.defaultService
            defaultService.foundationStore = ProjectStore()
        }
    }
    
    func registerNavigationBarAppearance() {
        let navigationBarAppearance = UINavigationBar.appearance()
        navigationBarAppearance.barTintColor = UIColor(red:0.20, green:0.51, blue:0.71, alpha:1.00)
        navigationBarAppearance.isTranslucent = true
        navigationBarAppearance.tintColor = UIColor.white
        navigationBarAppearance.backgroundColor = UIColor.clear
        navigationBarAppearance.barStyle = .blackTranslucent
        navigationBarAppearance.titleTextAttributes = [
            .foregroundColor: UIColor.white
        ]
    }
    
    func registerPageControlAppearance() {
        let pageControl = UIPageControl.appearance()
        pageControl.pageIndicatorTintColor = .gray
        pageControl.currentPageIndicatorTintColor = .darkGray
    }
}

