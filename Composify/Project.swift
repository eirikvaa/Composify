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
    var sections = List<Section>()

    init(title: String) {
        self.title = title
    }

    override required init() {
        super.init()
    }

    override static func primaryKey() -> String? {
        "id"
    }
}
