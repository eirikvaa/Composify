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
    func save(recording: Recording, to section: Section)
    func update(project: Project)
    func update(section: Section)
    func delete(section: Section)
    func delete(project: Project)
    func set(currentProject: Project?, currentSection: Section?)
    func getCurrentProjectAndSection() -> (Project?, Section?)
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

    func save(recording: Recording, to section: Section) {
        recordingDao.save(recording: recording, to: section)
    }

    func delete(section: Section) {
        sectionDao.delete(section: section)
    }

    func delete(project: Project) {
        projectDao.delete(project: project)
    }

    func set(currentProject: Project?, currentSection: Section?) {
        let userDefaults = UserDefaults.standard

        if let currentProject = currentProject {
            userDefaults.set(currentProject.id, forKey: "current.project")
        }

        if let currentSection = currentSection {
            userDefaults.set(currentSection.id, forKey: "current.section")
        }
    }

    func getCurrentProjectAndSection() -> (Project?, Section?) {
        let userDefaults = UserDefaults.standard
        let currentProjectId = userDefaults.string(forKey: "current.project")
        let currentSectionId = userDefaults.string(forKey: "current.section")

        guard let project = projectDao.getProjects().first(where: { $0.id == currentProjectId }) else {
            return (nil, nil)
        }

        guard let section = sectionDao.getSections(in: project).first(where: { $0.id == currentSectionId }) else {
            return (project, nil)
        }

        return (project, section)
    }
}
