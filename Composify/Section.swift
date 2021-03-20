//
//  Section.swift
//  Composify
//
//  Created by Eirik Vale Aase on 10.08.2016.
//  Copyright © 2016 Eirik Vale Aase. All rights reserved.
//

import Foundation
import RealmSwift

final class Section: EmbeddedObject {
    @objc dynamic var id = UUID().uuidString
    @objc dynamic var index = 0
    @objc dynamic var dateCreated = Date()
    @objc dynamic var title = ""

    let recordings = List<Recording>()
    let project = LinkingObjects(fromType: Project.self, property: "sections")

    init(title: String, index: Int) {
        self.title = title
        self.index = index
    }

    override required init() {
        super.init()
    }
}

extension Section: Comparable {
    static func < (lhs: Section, rhs: Section) -> Bool {
        lhs.index < rhs.index
    }
}
