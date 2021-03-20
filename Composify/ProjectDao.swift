//
//  ProjectDao.swift
//  Composify
//
//  Created by Eirik Vale Aase on 13/03/2021.
//  Copyright © 2021 Eirik Vale Aase. All rights reserved.
//

import Foundation
import RealmSwift

protocol ProjectDaoInjectable {
    var projectDao: ProjectDao { get }
}

extension ProjectDaoInjectable {
    var projectDao: ProjectDao {
        ProjectDaoImpl()
    }
}

class ProjectDaoInjectableImpl: ProjectDaoInjectable {}

protocol ProjectDao {
    func getProjects() -> [Project]
    func save(project: Project)
    func update<Value>(project: inout Project, keypath: WritableKeyPath<Project, Value>, value: Value)
    func delete(project: Project)
}

class ProjectDaoImpl: ProjectDao {
    func getProjects() -> [Project] {
        let realm = try! Realm()
        let recordings = realm.objects(Project.self)
        return Array(recordings)
    }

    func save(project: Project) {
        let realm = try! Realm()
        try! realm.write {
            realm.add(project, update: .modified)
        }
    }

    func update<Value>(project: inout Project, keypath: WritableKeyPath<Project, Value>, value: Value) {
        let realm = try! Realm()
        try! realm.write {
            project[keyPath: keypath] = value
        }
    }

    func delete(project: Project) {
        let realm = try! Realm()
        try! realm.write {
            // Since Section and Recording are embedded objects, they will be deleted when
            // a Project is deleted, as they are bound to the life cycle of the Project.
            realm.delete(project)
        }
    }
}
