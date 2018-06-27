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
    @objc dynamic var title = ""
    var sectionIDs = List<String>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

extension Project {
    var sections: [Section] {
        return sectionIDs
            .compactMap { RealmStore.shared.realm.object(ofType: Section.self, forPrimaryKey: $0) }
            .sorted()
    }
    
    static func allProjects() -> Results<Project> {
        return RealmStore.shared.realm
            .objects(Project.self)
            .sorted(byKeyPath: "title")
    }
    
    var recordings: [Recording] {
        return sections.reduce([], { (recordings: [Recording], section: Section) -> [Recording] in
            return recordings + section.recordings
        }).sorted()
    }
}

extension Project: Comparable {
    static func <(lhs: Project, rhs: Project) -> Bool {
        return lhs.title < rhs.title
    }
}

extension Project: FileSystemObject {
    var url: URL {
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentDirectory
            .appendingPathComponent(FileSystemDirectories.userProjects.rawValue)
            .appendingPathComponent(title)
    }
}
