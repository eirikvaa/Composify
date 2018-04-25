//
//  AppDelegate.swift
//  Composify
//
//  Created by Eirik Vale Aase on 17.07.2016.
//  Copyright © 2016 Eirik Vale Aase. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        setupCoreData()
        setupRemoteControlEvents()
        registerNavigationBarAppearance()

        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        CoreDataStack.sharedInstance.saveContext()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        CoreDataStack.sharedInstance.saveContext()
    }

}

private extension AppDelegate {
    func setupCoreData() {
        // `persistentContainer` is marked 'lazy', so initialize to ready it for use.
        _ = CoreDataStack.sharedInstance.viewContext
    }
    
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

