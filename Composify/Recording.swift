//
//  Recording.swift
//  Composify
//
//  Created by Eirik Vale Aase on 10.08.2016.
//  Copyright © 2016 Eirik Vale Aase. All rights reserved.
//

import Foundation
import RealmSwift

final class Recording: Object, ComposifyObject {
    @objc dynamic var id = UUID().uuidString
    @objc dynamic var title = ""
    @objc dynamic var project: Project?
    @objc dynamic var section: Section?
    @objc dynamic var dateCreated = Date()
    @objc dynamic var fileExtension = ""

    override static func primaryKey() -> String? {
        return R.DatabaseKeys.id
    }
}

extension Recording: AudioPlayable {
    var url: URL {
        return R.URLs.recordingsDirectory
            .appendingPathComponent(id)
            .appendingPathExtension(fileExtension)
    }
}

extension Recording: Comparable {
    static func < (lhs: Recording, rhs: Recording) -> Bool {
        return lhs.title < rhs.title
    }
}
