//
//  RealmStore.swift
//  Composify
//
//  Created by Eirik Vale Aase on 16.06.2018.
//  Copyright © 2018 Eirik Vale Aase. All rights reserved.
//

import Foundation
import RealmSwift

struct RealmStore {
    typealias ComposifyObject = Object & FileSystemObject
    let realm = try! Realm()
    
    static let shared = RealmStore()
    private init() {
        realm.autorefresh = true
    }
    
    func save(_ object: ComposifyObject, update: Bool = false) {
        try! realm.write {
            realm.add(object, update: update)
        }
    }
    
    func delete(_ object: ComposifyObject) {
        try! realm.write {
            switch object {
            case let project as Project:
                realm.delete(project.recordings)
                realm.delete(project.sections)
                realm.delete(project)
            case let section as Section:
                realm.delete(section.recordings)
                realm.delete(section)
            case let recording as Recording:
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
