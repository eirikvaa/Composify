//
//  CoreDataStack.swift
//  Piece
//
//  Created by Eirik Vale Aase on 08.08.2016.
//  Copyright © 2016 Eirik Vale Aase. All rights reserved.
//

import Foundation
import CoreData

/**
A class for setting up the core data stack. Uses the new features of Core Data to simplify this process.

- Important: CoreDataStack implements a singletone - `sharedInstance` - since it only uses one context and a simple model. Because of this, it is important to note that the `init()` method is private so third parties can't instantiate it more than once.
- Author: Eirik Vale Aase
*/
class CoreDataStack {

	// MARK: Properties
	static let sharedInstance = CoreDataStack()

	lazy var persistentContainer: NSPersistentContainer = {
		let container = NSPersistentContainer(name: "Piece")
		container.loadPersistentStores(completionHandler: { (storeDescription, error) in
			if let error = error as NSError? {
				fatalError("Unresolved error \(error), \(error.userInfo)")
			}
		})
		return container
	}()

	// MARK: Initialization
	private init() { }

	// MARK: - Saving
	func saveContext () {
		let context = persistentContainer.viewContext
		if context.hasChanges {
			do {
				try context.save()
			} catch {
				let nserror = error as NSError
				fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
			}
		}
	}
}
