//
//  Repository.swift
//  Composify
//
//  Created by Eirik Vale Aase on 12.07.2018.
//  Copyright © 2018 Eirik Vale Aase. All rights reserved.
//

import Foundation
import RealmSwift

/// The basic interface that a database service must implement.
/// This way we can abstract away all the bullshit, and just
/// use these specific type-free methods instead of references
/// to Realm or Core Data or something else.
protocol Repository {
    associatedtype T: Object
    
    @discardableResult
    func save(object: T) -> Bool
    
    func get(id: String) -> T?
    
    @discardableResult
    func update<V>(id: String, value: V, keyPath: WritableKeyPath<T, V>) -> Bool
    
    @discardableResult
    func delete(object: T) -> Bool
}
