//
//  Section.swift
//  Composify
//
//  Created by Eirik Vale Aase on 10.08.2016.
//  Copyright © 2016 Eirik Vale Aase. All rights reserved.
//

import Foundation
import RealmSwift

final class Section: Object {
    @objc dynamic var id = UUID().uuidString
    @objc dynamic var index = 0
    @objc dynamic var dateCreated = Date()
    @objc dynamic var title = ""
    @objc dynamic var project: Project?
    let recordings = List<Recording>()

    init(title: String, project: Project?) {
        self.title = title
        self.project = project
    }

    override required init() {
        super.init()
    }

    override static func primaryKey() -> String? {
        "id"
    }
}

extension Section: Comparable {
    static func < (lhs: Section, rhs: Section) -> Bool {
        lhs.index < rhs.index
    }
}
