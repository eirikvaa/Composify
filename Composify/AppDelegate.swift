//
//  AppDelegate.swift
//  Composify
//
//  Created by Eirik Vale Aase on 17.07.2016.
//  Copyright © 2016 Eirik Vale Aase. All rights reserved.
//

import UIKit
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let userDefaults = UserDefaults.standard
        if userDefaults.value(forKey: "projectStoreID") as? String == nil {
            RealmStore.shared.projectStore = ProjectStore()
        }
        
        setupRemoteControlEvents()
        registerNavigationBarAppearance()
        
        let pageControl = UIPageControl.appearance()
        pageControl.pageIndicatorTintColor = .gray
        pageControl.currentPageIndicatorTintColor = .darkGray
        
        return true
    }
}

private extension AppDelegate {
    func setupRemoteControlEvents() {
        // To be able to get recording information and playback controls in control center.
        UIApplication.shared.beginReceivingRemoteControlEvents()
    }
    
    func registerNavigationBarAppearance() {
        let navigationBarAppearance = UINavigationBar.appearance()
        navigationBarAppearance.barTintColor = UIColor(red:0.20, green:0.51, blue:0.71, alpha:1.00)
        navigationBarAppearance.isTranslucent = true
        navigationBarAppearance.tintColor = UIColor.white
        navigationBarAppearance.backgroundColor = UIColor.clear
        navigationBarAppearance.barStyle = .blackTranslucent
        navigationBarAppearance.titleTextAttributes = [
            NSAttributedStringKey.foregroundColor: UIColor.white
        ]
    }
}

