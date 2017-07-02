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

- Important: CoreDataStack implements a singletone - `sharedInstance` - since it only uses one context and a simple model. Because of this, it is important to note that the `init()` method is private so third parties can't instantiate it more than once. Also, remember to write `_ = CoreDataStack.sharedInstance.viewContext` in your AppDelegate.
- Author: Eirik Vale Aase
*/

final class CoreDataStack {

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

    lazy var viewContext: NSManagedObjectContext = {
        return self.persistentContainer.viewContext
    }()

    // MARK: Initialization
    private init() {
    }

    // MARK: - Saving
    func saveContext() {
        guard persistentContainer.viewContext.hasChanges else {
            return
        }

        do {
            try persistentContainer.viewContext.save()
        } catch let error as NSError {
            print("Unresolved error \(error), \(error.userInfo)")
        }
    }
}
