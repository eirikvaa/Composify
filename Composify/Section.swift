//
//  Section.swift
//  Composify
//
//  Created by Eirik Vale Aase on 10.08.2016.
//  Copyright © 2016 Eirik Vale Aase. All rights reserved.
//

import Foundation
import RealmSwift

class Section: Object {
    @objc dynamic var id = UUID().uuidString
    @objc dynamic var title = ""
    @objc dynamic var project: Project?
    var recordingIDs = List<String>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

extension Section {
    var recordings: [Recording] {
        return recordingIDs
            .compactMap { RealmStore.shared.realm.object(ofType: Recording.self, forPrimaryKey: $0)}
            .sorted()
    }
}

extension Section: FileSystemObject {
    var url: URL {
        return project!.url
            .appendingPathComponent(id)
    }
}

extension Section: Comparable {
    static func < (lhs: Section, rhs: Section) -> Bool {
        return lhs.title <= rhs.title
    }
}

extension String {
    var correspondingSection: Section? {
        return RealmStore.shared.realm.object(ofType: Section.self, forPrimaryKey: self)
    }
}
