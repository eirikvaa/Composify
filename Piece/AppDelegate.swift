//
//  AppDelegate.swift
//  Piece
//
//  Created by Eirik Vale Aase on 17.07.2016.
//  Copyright © 2016 Eirik Vale Aase. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?
	var testInitializer: TestInitializer!

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.
		
		let launchArguments = ProcessInfo.processInfo.arguments
		testInitializer = TestInitializer(arguments: launchArguments)
		testInitializer.setupTestingMode()
		
		let appearence = UINavigationBar.appearance()
		appearence.barTintColor = UIColor(red: 231.0/255.0, green: 76.0/255.0, blue: 60.0/255.0, alpha: 1.0)
		appearence.isTranslucent = true
		appearence.tintColor = UIColor.white
		appearence.backgroundColor = UIColor.clear
		appearence.barStyle = .blackTranslucent
		appearence.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
		
		return true
	}

	func applicationDidEnterBackground(_ application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
		if !testInitializer.active {
			CoreDataStack.sharedInstance.saveContext()
		}
	}

	func applicationWillTerminate(_ application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
		
		if !testInitializer.active {
			CoreDataStack.sharedInstance.saveContext()
		} else {
			testInitializer.reset()
		}
		
	}

}

