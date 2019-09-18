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
    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        registerNavigationBarAppearance()
        createRecordingsDirectoryIfNeeded()

        return true
    }
}

private extension AppDelegate {
    func createRecordingsDirectoryIfNeeded() {
        FileManager.default.createRecordingsDirectoryIfNeeded()
    }

    func registerNavigationBarAppearance() {
        let navigationBarAppearance = UINavigationBar.appearance()
        navigationBarAppearance.barTintColor = R.Colors.cardinalRed
        navigationBarAppearance.isTranslucent = true
        navigationBarAppearance.tintColor = UIColor.white
        navigationBarAppearance.backgroundColor = UIColor.clear
        navigationBarAppearance.barStyle = .black
        navigationBarAppearance.isTranslucent = true
        navigationBarAppearance.titleTextAttributes = [
            .foregroundColor: UIColor.white,
        ]
    }
}
