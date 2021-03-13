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
}

class SectionDaoImpl: SectionDao {
    func getSections(in project: Project) -> [Section] {
        let realm = try! Realm()
        let sections = realm.objects(Section.self).filter { $0.project == project }
        return Array(sections)
    }
    
    func save(section: Section, to project: Project) {
        let realm = try! Realm()
        try! realm.write {
            section.project = project
            project.sections.append(section)
        }
    }
}
