//
//  SectionDao.swift
//  Composify
//
//  Created by Eirik Vale Aase on 13/03/2021.
//  Copyright © 2021 Eirik Vale Aase. All rights reserved.
//

import Foundation
import RealmSwift

protocol SectionDaoInjectable {
    var sectionDao: SectionDao { get }
}

extension SectionDaoInjectable {
    var sectionDao: SectionDao {
        SectionDaoImpl()
    }
}

class SectionDaoInjectableImpl: SectionDaoInjectable {}

protocol SectionDao {
    func getSections(in project: Project) -> [Section]
    func save(section: Section, to project: Project)
    func update<Value>(section: inout Section, keypath: WritableKeyPath<Section, Value>, value: Value)
    func delete(section: Section)
}

class SectionDaoImpl: SectionDao {
    func getSections(in project: Project) -> [Section] {
        Array(project.sections)
    }

    func save(section: Section, to project: Project) {
        let realm = try! Realm()
        try! realm.write {
            project.sections.append(Section(title: "Yo", index: 10))
        }
    }
    func update<Value>(section: inout Section, keypath: WritableKeyPath<Section, Value>, value: Value) {
        let realm = try! Realm()
        try! realm.write {
            section[keyPath: keypath] = value
        }
    }

    func delete(section: Section) {
        let realm = try! Realm()
        try! realm.write {
            realm.delete(section.recordings)
            realm.delete(section)
        }
    }
}
