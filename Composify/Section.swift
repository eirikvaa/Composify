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
    let recordings = List<Recording>()

    init(title: String, project: Project?) {
        self.title = title
        self.index = project?.nextSectionIndex ?? 0
        self.project = project
    }

    override required init() {
        super.init()
    }

    override static func primaryKey() -> String? {
        R.DatabaseKeys.id
    }
}

extension UserDefaults {
    func lastSection() -> Section? {
        guard let realm = try? Realm() else {
            return nil
        }

        guard let id = UserDefaults.standard.string(
                forKey: R.UserDefaults.lastSectionID
        ) else { return nil }
        return realm.object(ofType: Section.self, forPrimaryKey: id)
    }
}

extension Section: Comparable {
    static func < (lhs: Section, rhs: Section) -> Bool {
        lhs.index < rhs.index
    }
}
