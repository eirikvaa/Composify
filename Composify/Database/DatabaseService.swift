//
//  DatabaseService.swift
//  Composify
//
//  Created by Eirik Vale Aase on 12.07.2018.
//  Copyright © 2018 Eirik Vale Aase. All rights reserved.
//

import Foundation

/// The basic interface that a database service must implement.
/// This way we can abstract away all the bullshit, and just
/// use these specific type-free methods instead of references
/// to Realm or Core Data or something else.
protocol DatabaseService {
    func save(_ object: ComposifyObject)
    func delete(_ object: ComposifyObject)
    func rename(_ object: ComposifyObject, to newName: String)
    func performOperation(_ operation: () -> Void)
}
