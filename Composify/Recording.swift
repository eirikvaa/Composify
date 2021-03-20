//
//  Recording.swift
//  Composify
//
//  Created by Eirik Vale Aase on 10.08.2016.
//  Copyright © 2016 Eirik Vale Aase. All rights reserved.
//

import Foundation
import RealmSwift

final class Recording: EmbeddedObject {
    @objc dynamic var id = UUID().uuidString
    @objc dynamic var title = ""
    @objc dynamic var dateCreated = Date()
    @objc dynamic var fileExtension = "caf"
    @objc dynamic var url = ""

    let section = LinkingObjects(fromType: Section.self, property: "recordings")

    init(title: String, url: String) {
        self.title = title
        self.url = url
    }

    override required init() {
        super.init()
    }
}
