//
//  RealmStore.swift
//  Composify
//
//  Created by Eirik Vale Aase on 16.06.2018.
//  Copyright © 2018 Eirik Vale Aase. All rights reserved.
//

import Foundation
import RealmSwift

final class ProjectStore: Object {
    @objc dynamic var id = UUID().uuidString
    var projectIDs = List<String>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

typealias ComposifyObject = Object & FileSystemObject

struct RealmStore {
    
    let realm = try! Realm()
    
    static var shared = RealmStore()
    private init() {}
    
    private var _projectStore: ProjectStore?
    var projectStore: ProjectStore? {
        set {
            guard let projectStore = newValue else { return }
            UserDefaults.standard.set(projectStore.id, forKey: "projectStoreID")
            try! realm.write {
                realm.add(projectStore, update: true)
            }
            _projectStore = newValue
        } get {
            guard let id = UserDefaults.standard.projectStoreID else { return nil }
            return realm.object(ofType: ProjectStore.self, forPrimaryKey: id)
        }
    }
    
    mutating func save(_ object: ComposifyObject, update: Bool = false) {
        defer {
            try! realm.write {
                realm.add(object, update: update)
            }
        }
        
        try! realm.write {
            switch object {
            case let project as Project:
                projectStore?.projectIDs.append(project.id)
            case let section as Section:
                section.project?.sectionIDs.append(section.id)
            case let recording as Recording:
                recording.section?.recordingIDs.append(recording.id)
            default:
                break
            }
        }
    }
    
    mutating func delete(_ object: ComposifyObject) {
        try! realm.write {
            switch object {
            case let project as Project:
                if let index = projectStore?.projectIDs.index(of: project.id) {
                    projectStore?.projectIDs.remove(at: index)
                }
                let realm = RealmStore.shared.realm
                project.sectionIDs
                    .compactMap { realm.object(ofType: Section.self, forPrimaryKey: $0) }
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
    
    func rename(_ object: ComposifyObject, to title: String) {
        try! realm.write {
            switch object {
            case let project as Project:
                project.title = title
            case let section as Section:
                section.title = title
            case let recording as Recording:
                recording.title = title
            default:
                break
            }
        }
    }
}

extension UserDefaults {
    var projectStoreID: String? {
        return value(forKey: "projectStoreID") as? String
    }
}
