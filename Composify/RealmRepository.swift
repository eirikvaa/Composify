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
    typealias T = O
    typealias D = Realm
    
    @discardableResult
    func save(object: T) -> Bool {
        guard let realm = try? Realm() else {
            fatalError("Unable to instantiate Realm instance!")
        }
        
        try! realm.write {
            realm.add(object)
        }
        
        return true
    }
    
    func get(id: String) -> T? {
        guard let realm = try? Realm() else {
            fatalError("Unable to instantiate Realm instance!")
        }
        
        return realm.object(ofType: T.self, forPrimaryKey: id)
    }
    
    func getAll() -> Results<T> {
        guard let realm = try? Realm() else {
            fatalError("Unable to instantiate Realm instance!")
        }
        
        return realm.objects(T.self)
    }
    
    @discardableResult
    func update<V>(id: String, value: V, keyPath: WritableKeyPath<T, V>) -> Bool {
        guard let realm = try? Realm() else {
            fatalError("Unable to instantiate Realm instance!")
        }
        
        guard var object = realm.object(ofType: T.self, forPrimaryKey: id) else {
            return false
        }
        
        try! realm.write {
            object[keyPath: keyPath] = value
        }
        
        return true
    }
    
    @discardableResult
    func delete(object: T) -> Bool {
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

extension Repository where T: Object {
    func getAll() -> Results<T> {
        guard let realm = try? Realm() else {
            fatalError("Unable to instantiate Realm instance!")
        }
        
        return realm.objects(T.self)
    }
}

extension Repository where T == Recording {
    /// Save a recording and add it to a section's recordings
    /// - Parameters:
    ///     - recording: Recording to be added
    ///     - section: The section into which a recording should be included
    /// - Returns: If the operation was successful or not
    @discardableResult
    func save(recording: T, to section: Section) -> Bool {
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

extension Repository where T == Section {
    /// Save a section and add it to a projects's sections
    /// - Parameters:
    ///     - section: Section to be added
    ///     - project: The project into which a section should be included
    /// - Returns: If the operation was successful or not
    @discardableResult
    func save(section: T, to project: Project) -> Bool {
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
