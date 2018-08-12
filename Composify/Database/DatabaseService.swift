//
//  DatabaseService.swift
//  Composify
//
//  Created by Eirik Vale Aase on 12.07.2018.
//  Copyright © 2018 Eirik Vale Aase. All rights reserved.
//

import Foundation

/// The basic object that the common DatabaseService protocol uses.
protocol DatabaseObject {}

/// A special object that is implemented by the object that loads
/// stuff. For example, with the RealmDatabaseService, this is the
/// ProjectStore object, because it has a reference to all project
/// identification numbers.
protocol DatabaseFoundationObject {
    var identification: String { get }
    var projectIDs: [String] { get set }
}

/// The basic interface that a database service must implement.
/// This way we can abstract away all the bullshit, and just
/// use these specific type-free methods instead of references
/// to Realm or Core Data or something else.
protocol DatabaseService {
    var foundationStore: DatabaseFoundationObject? { get set }
    static var sharedInstance: DatabaseService? { get set }
    static func defaultService() -> DatabaseService
    
    mutating func save(_ object: DatabaseObject)
    mutating func delete(_ object: DatabaseObject)
    mutating func rename(_ object: DatabaseObject, to newName: String)
}
