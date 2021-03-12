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
    associatedtype Item: Object

    @discardableResult
    func save(object: Item) -> Bool

    func get(id: String) -> Item?

    @discardableResult
    func update<V>(object: inout Item, value: V, keyPath: WritableKeyPath<Item, V>) -> Bool

    @discardableResult
    func delete(object: Item) -> Bool
}
