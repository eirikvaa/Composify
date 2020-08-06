//
//  RealmDatabaseService.swift
//  Composify
//
//  Created by Eirik Vale Aase on 16.06.2018.
//  Copyright © 2018 Eirik Vale Aase. All rights reserved.
//

import Foundation
import RealmSwift

func performRealmOperation(block: (Realm) -> Void) {
    let realm = try! Realm()
    
    try! realm.write {
        block(realm)
    }
}

struct ProjectRepository: Repository {
    typealias T = Project
    
    @discardableResult
    func save(object: Project) -> Bool {
        guard let realm = try? Realm() else {
            fatalError("Unable to instantiate Realm instance!")
        }
        
        try! realm.write {
            realm.add(object)
        }
        
        return true
    }
    
    func get(id: String) -> Project? {
        guard let realm = try? Realm() else {
            fatalError("Unable to instantiate Realm instance!")
        }
        
        return realm.object(ofType: Project.self, forPrimaryKey: id)
    }
    
    func getAll() -> Results<Project> {
        guard let realm = try? Realm() else {
            fatalError("Unable to instantiate Realm instance!")
        }
        
        return realm.objects(Project.self)
    }
    
    @discardableResult
    func update<V>(id: String, value: V, keyPath: WritableKeyPath<Project, V>) -> Bool {
        guard let realm = try? Realm() else {
            fatalError("Unable to instantiate Realm instance!")
        }
        
        guard var object = realm.object(ofType: Project.self, forPrimaryKey: id) else {
            return false
        }
        
        try! realm.write {
            object[keyPath: keyPath] = value
        }
        
        return true
    }
    
    @discardableResult
    func delete(id: String) -> Bool {
        guard let realm = try? Realm() else {
            fatalError("Unable to instantiate Realm instance!")
        }
        
        guard let object = realm.object(ofType: Project.self, forPrimaryKey: id) else {
            return false
        }
        
        try! realm.write {
            for section in object.sections {
                realm.delete(section.recordings)
            }
            
            realm.delete(object.sections)
            realm.delete(object)
        }
        
        return true
    }
}



struct SectionRepository: Repository {
    typealias T = Section
    
    @discardableResult
    func save(object: Section) -> Bool {
        guard let realm = try? Realm() else {
            fatalError("Unable to instantiate Realm instance!")
        }
        
        try! realm.write {
            realm.add(object)
        }
        
        return true
    }
    
    func get(id: String) -> Section? {
        guard let realm = try? Realm() else {
            fatalError("Unable to instantiate Realm instance!")
        }
        
        return realm.object(ofType: Section.self, forPrimaryKey: id)
    }
    
    func getAll() -> Results<Section> {
        guard let realm = try? Realm() else {
            fatalError("Unable to instantiate Realm instance!")
        }
        
        return realm.objects(Section.self)
    }
    
    @discardableResult
    func update<V>(id: String, value: V, keyPath: WritableKeyPath<Section, V>) -> Bool {
        guard let realm = try? Realm() else {
            fatalError("Unable to instantiate Realm instance!")
        }
        
        guard var object = realm.object(ofType: Section.self, forPrimaryKey: id) else {
            return false
        }
        
        try! realm.write {
            object[keyPath: keyPath] = value
        }
        
        return true
    }
    
    @discardableResult
    func delete(id: String) -> Bool {
        guard let realm = try? Realm() else {
            fatalError("Unable to instantiate Realm instance!")
        }
        
        guard let object = realm.object(ofType: Section.self, forPrimaryKey: id) else {
            return false
        }
        
        try! realm.write {
            realm.delete(object.recordings)
            realm.delete(object)
        }
        
        return true
    }
}

struct RecordingRepository: Repository {
    typealias T = Recording
    
    @discardableResult
    func save(object: Recording) -> Bool {
        guard let realm = try? Realm() else {
            fatalError("Unable to instantiate Realm instance!")
        }
        
        try! realm.write {
            realm.add(object)
        }
        
        return true
    }
    
    func get(id: String) -> Recording? {
        guard let realm = try? Realm() else {
            fatalError("Unable to instantiate Realm instance!")
        }
        
        return realm.object(ofType: Recording.self, forPrimaryKey: id)
    }
    
    func getAll() -> Results<Recording> {
        guard let realm = try? Realm() else {
            fatalError("Unable to instantiate Realm instance!")
        }
        
        return realm.objects(Recording.self)
    }
    
    @discardableResult
    func update<V>(id: String, value: V, keyPath: WritableKeyPath<Recording, V>) -> Bool {
        guard let realm = try? Realm() else {
            fatalError("Unable to instantiate Realm instance!")
        }
        
        guard var object = realm.object(ofType: Recording.self, forPrimaryKey: id) else {
            return false
        }
        
        try! realm.write {
            object[keyPath: keyPath] = value
        }
        
        return true
    }
    
    @discardableResult
    func delete(id: String) -> Bool {
        guard let realm = try? Realm() else {
            fatalError("Unable to instantiate Realm instance!")
        }
        
        guard let object = realm.object(ofType: Recording.self, forPrimaryKey: id) else {
            return false
        }
        
        try! realm.write {
            realm.delete(object)
        }
        
        return true
    }
}

struct RealmDatabaseService {
    func save(_ object: Project) {
        
    }
    
    func delete(_ object: Project) {
        
    }
    
    func rename(_ object: Project, to newName: String) {
        
    }
    
    typealias T = Project
    func save(_ object: ComposifyObject) {
        let realm = try! Realm()

        try! realm.write {
            if let realmObject = object as? Object {
                realm.add(realmObject, update: .all)
            }
        }
    }

    func delete(_ object: ComposifyObject) {
        let realm = try! Realm()

        try! realm.write {
            switch object {
            case let project as Project:
                deleteProject(project)
            case let section as Section:
                deleteSection(section)
            case let recording as Recording:
                deleteRecording(recording)
            default:
                break
            }
        }
    }

    func rename(_ object: ComposifyObject, to newName: String) {
        let realm = try! Realm()

        try! realm.write {
            switch object {
            case let project as Project:
                project.title = newName
            case let section as Section:
                section.title = newName
            case let recording as Recording:
                recording.title = newName
            default:
                break
            }
        }
    }

    func performOperation(_ operation: () -> Void) {
        let realm = try! Realm()

        try! realm.write {
            operation()
        }
    }
}

private extension RealmDatabaseService {
    func deleteProject(_ project: Project) {
        let realm = try! Realm()
        
        for section in project.sections {
            realm.delete(section.recordings)
        }

        realm.delete(project.sections)
        realm.delete(project)
    }

    func deleteSection(_ section: Section) {
        let realm = try! Realm()
        
        realm.delete(section.recordings)
        realm.delete(section)
    }

    func deleteRecording(_ recording: Recording) {
        let realm = try! Realm()

        realm.delete(recording)
    }
}
