//
//  RealmDatabaseService.swift
//  Composify
//
//  Created by Eirik Vale Aase on 16.06.2018.
//  Copyright © 2018 Eirik Vale Aase. All rights reserved.
//

import Foundation
import RealmSwift

typealias ComposifyObject = Object & FileSystemObject

struct RealmDatabaseService: DatabaseService {
    
    var foundationStore: DatabaseFoundationObject? {
        get {
            return realm.objects(ProjectStore.self).first
        }
        set {
            guard let foundationStore = newValue as? ProjectStore else { return }
            if !realm.isInWriteTransaction && !realm.objects(ProjectStore.self).contains(foundationStore) {
                try! realm.write {
                    realm.add(foundationStore, update: true)
                }
                UserDefaults.standard.set(foundationStore.identification, forKey: "projectStoreID")
            }
        }
    }
    
    let realm = try! Realm()
    
    private init() {}
    static var sharedInstance: DatabaseService?
    static func defaultService() -> DatabaseService {
        if sharedInstance == nil {
            sharedInstance = RealmDatabaseService()
        }
        
        return sharedInstance!
    }
    
    mutating func save(_ object: DatabaseObject) {
        try! realm.write {
            switch object {
            case let project as Project:
                foundationStore?.projectIDs.append(project.id)
            case let section as Section:
                section.project?.sectionIDs.append(section.id)
            case let recording as Recording:
                recording.section?.recordingIDs.append(recording.id)
            default:
                break
            }
            
            if let realmObject = object as? Object {
                realm.add(realmObject, update: true)
            }
        }
    }
    
    mutating func delete(_ object: DatabaseObject) {
        let _self = self
        try! realm.write {
            switch object {
            case let project as Project:
                if let index = foundationStore?.projectIDs.index(of: project.id) {
                    foundationStore?.projectIDs.remove(at: index)
                }
                project.sectionIDs
                    .compactMap { _self.realm.object(ofType: Section.self, forPrimaryKey: $0) }
                    .forEach {
                        realm.delete($0.recordings)
                        realm.delete($0)
                }
                realm.delete(project)
            case let section as Section:
                if let index = section.project?.sectionIDs.index(of: section.id) {
                    section.project?.sectionIDs.remove(at: index)
                }
                realm.delete(section.recordings)
                realm.delete(section)
            case let recording as Recording:
                if let index = recording.section?.recordingIDs.index(of: recording.id) {
                    recording.section?.recordingIDs.remove(at: index)
                }
                realm.delete(recording)
            default:
                break
            }
        }
    }
    
    func rename(_ object: DatabaseObject, to newName: String) {
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
}
