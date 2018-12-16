//
//  Project.swift
//  Composify
//
//  Created by Eirik Vale Aase on 10.08.2016.
//  Copyright © 2016 Eirik Vale Aase. All rights reserved.
//

import Foundation
import RealmSwift

final class Project: Object {
    @objc dynamic var id = UUID().uuidString
    @objc dynamic var dateCreated = Date()
    @objc dynamic var title = ""
    var sectionIDs = List<String>()

    override static func primaryKey() -> String? {
        return R.DatabaseKeys.id
    }
}

extension Project: DatabaseObject {}

extension UserDefaults {
    func lastProject() -> Project? {
        guard let realm = try? Realm() else { return nil }
        guard let id = UserDefaults.standard.string(forKey: R.UserDefaults.lastProjectID) else { return nil }
        return realm.object(ofType: Project.self, forPrimaryKey: id)
    }
}

extension Project {
    static func projects() -> [Project] {
        let realm = try! Realm()
        let projectStore = DatabaseServiceFactory.defaultService.foundationStore
        return projectStore?.projectIDs
            .compactMap { realm.object(ofType: Project.self, forPrimaryKey: $0) }
            .sorted() ?? []
    }

    var sections: [Section] {
        return sectionIDs
            .compactMap { self.realm?.object(ofType: Section.self, forPrimaryKey: $0) }
            .sorted()
    }

    var recordings: [Recording] {
        return sections
            .reduce([]) { (recordings: [Recording], section: Section) -> [Recording] in
                recordings + section.recordings
            }
            .sorted()
    }
}

extension Project: Comparable {
    static func < (lhs: Project, rhs: Project) -> Bool {
        return lhs.title < rhs.title
    }
}

extension Project: FileSystemObject {
    var url: URL {
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentDirectory
            .appendingPathComponent(FileSystemDirectories.userProjects.rawValue)
            .appendingPathComponent(id)
    }
}

extension String {
    var correspondingProject: Project? {
        guard let realm = try? Realm() else { return nil }
        return realm.object(ofType: Project.self, forPrimaryKey: self)
    }
}

extension Project {
    static func createProject(withTitle title: String, then completionHandler: (_ project: Project) -> Void) throws {
        let project = Project()
        project.title = title

        var databaseService = DatabaseServiceFactory.defaultService
        databaseService.save(project)

        try FileManager.default.save(project)

        completionHandler(project)
    }
}
