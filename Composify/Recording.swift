//
//  Recording.swift
//  Composify
//
//  Created by Eirik Vale Aase on 10.08.2016.
//  Copyright © 2016 Eirik Vale Aase. All rights reserved.
//

import Foundation
import RealmSwift

final class Recording: Object {
    @objc dynamic var id = UUID().uuidString
    @objc dynamic var title = ""
    @objc dynamic var project: Project?
    @objc dynamic var section: Section?
    @objc dynamic var dateCreated = Date()
    @objc dynamic var fileExtension = "caf"

    init(title: String, section: Section?) {
        self.title = title
        self.section = section
        self.project = section?.project
    }

    override required init() {
        super.init()
    }

    override static func primaryKey() -> String? {
        "id"
    }
}
