//
//  RealmRepository.swift
//  Composify
//
//  Created by Eirik Vale Aase on 16.06.2018.
//  Copyright © 2018 Eirik Vale Aase. All rights reserved.
//

import Foundation
import RealmSwift

struct RealmRepository<O: Object>: Repository {
    typealias Item = O
    typealias D = Realm

    @discardableResult
    func save(object: Item) -> Bool {
        guard let realm = try? Realm() else {
            fatalError("Unable to instantiate Realm instance!")
        }

        try! realm.write {
            realm.add(object)
        }

        return true
    }

    func get(id: String) -> Item? {
        guard let realm = try? Realm() else {
            fatalError("Unable to instantiate Realm instance!")
        }

        return realm.object(ofType: Item.self, forPrimaryKey: id)
    }

    func getAll() -> Results<Item> {
        guard let realm = try? Realm() else {
            fatalError("Unable to instantiate Realm instance!")
        }

        return realm.objects(Item.self)
    }

    @discardableResult
    func update<V>(object: inout Item, value: V, keyPath: WritableKeyPath<Item, V>) -> Bool {
        guard let realm = try? Realm() else {
            fatalError("Unable to instantiate Realm instance!")
        }

        try! realm.write {
            object[keyPath: keyPath] = value
        }

        return true
    }

    @discardableResult
    func delete(object: Item) -> Bool {
        guard let realm = try? Realm() else {
            fatalError("Unable to instantiate Realm instance!")
        }

        try! realm.write {
            switch object {
            case let project as Project:
                for section in project.sections {
                    realm.delete(section.recordings)
                }

                realm.delete(project.sections)
            case let section as Section:
                realm.delete(section.recordings)
            default:
                break
            }

            realm.delete(object)
        }

        return true
    }
}

extension Repository where Item: Object {
    func getAll() -> Results<Item> {
        guard let realm = try? Realm() else {
            fatalError("Unable to instantiate Realm instance!")
        }

        return realm.objects(Item.self)
    }
}

extension Repository where Item == Recording {
    /// Save a recording and add it to a section's recordings
    /// - Parameters:
    ///     - recording: Recording to be added
    ///     - section: The section into which a recording should be included
    /// - Returns: If the operation was successful or not
    @discardableResult
    func save(recording: Item, to section: Section) -> Bool {
        guard let realm = try? Realm() else {
            fatalError("Unable to instantiate Realm instance!")
        }

        try! realm.write {
            realm.add(recording)
            section.recordings.append(recording)
        }

        return true
    }
}

extension Repository where Item == Section {
    /// Save a section and add it to a projects's sections
    /// - Parameters:
    ///     - section: Section to be added
    ///     - project: The project into which a section should be included
    /// - Returns: If the operation was successful or not
    @discardableResult
    func save(section: Item, to project: Project) -> Bool {
        guard let realm = try? Realm() else {
            fatalError("Unable to instantiate Realm instance!")
        }

        try! realm.write {
            realm.add(section)
            project.sections.append(section)
        }

        return true
    }
}
