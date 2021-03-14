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
    func update(project: Project)
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
            realm.add(project)
        }
    }

    func update(project: Project) {
        let realm = try! Realm()
        try! realm.write {
            realm.add(project, update: .all)
        }
    }

    func delete(project: Project) {
        let realm = try! Realm()
        try! realm.write {
            for section in project.sections {
                realm.delete(section.recordings)
            }

            realm.delete(project.sections)
            realm.delete(project)
        }
    }
}
