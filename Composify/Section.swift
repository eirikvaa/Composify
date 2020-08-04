//
//  Section.swift
//  Composify
//
//  Created by Eirik Vale Aase on 10.08.2016.
//  Copyright © 2016 Eirik Vale Aase. All rights reserved.
//

import Foundation
import RealmSwift

final class Section: Object, ComposifyObject {
    @objc dynamic var id = UUID().uuidString
    @objc dynamic var index = 0
    @objc dynamic var dateCreated = Date()
    @objc dynamic var title = ""
    @objc dynamic var project: Project?
    var recordingIDs = List<String>()

    override static func primaryKey() -> String? {
        R.DatabaseKeys.id
    }
}

extension Section {
    var recordings: [Recording] {
        recordingIDs
            .compactMap { self.realm?.object(ofType: Recording.self, forPrimaryKey: $0) }
            .sorted()
    }
}

extension UserDefaults {
    func lastSection() -> Section? {
        guard let realm = try? Realm() else { return nil }
        guard let id = UserDefaults.standard.string(forKey: R.UserDefaults.lastSectionID) else { return nil }
        return realm.object(ofType: Section.self, forPrimaryKey: id)
    }
}

extension Section: Comparable {
    static func < (lhs: Section, rhs: Section) -> Bool {
        lhs.index < rhs.index
    }
}
