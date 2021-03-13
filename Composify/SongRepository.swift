//
//  SongRepository.swift
//  Composify
//
//  Created by Eirik Vale Aase on 13/03/2021.
//  Copyright © 2021 Eirik Vale Aase. All rights reserved.
//

import Foundation

protocol SongRepositoryInjectable {
    var songRepository: SongRepository { get }
}

extension SongRepositoryInjectable {
    var songRepository: SongRepository {
        SongRepositoryImpl()
    }
}

protocol SongRepository {
    func getProjects() -> [Project]
    func getSections(in project: Project) -> [Section]
    func getRecordings(in section: Section) -> [Recording]
    func save(project: Project)
    func save(section: Section, to project: Project)
    func update(project: Project)
    func update(section: Section)
}

class SongRepositoryImpl: SongRepository,
                          ProjectDaoInjectable,
                          SectionDaoInjectable,
                          RecordingDaoInjectable {
    func getProjects() -> [Project] {
        projectDao.getProjects()
    }
    func getSections(in project: Project) -> [Section] {
        sectionDao.getSections(in: project)
    }
    func getRecordings(in section: Section) -> [Recording] {
        recordingDao.getRecordings(in: section)
    }

    func save(project: Project) {
        projectDao.save(project: project)
    }

    func update(project: Project) {
        projectDao.update(project: project)
    }

    func update(section: Section) {
        sectionDao.update(section: section)
    }

    func save(section: Section, to project: Project) {
        sectionDao.save(section: section, to: project)
    }
}
