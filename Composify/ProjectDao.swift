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
}

class ProjectDaoImpl: ProjectDao {
    func getProjects() -> [Project] {
        let realm = try! Realm()
        let recordings = realm.objects(Project.self)
        return Array(recordings)
    }
}
