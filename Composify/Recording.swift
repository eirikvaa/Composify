//
//  Recording.swift
//  Composify
//
//  Created by Eirik Vale Aase on 10.08.2016.
//  Copyright © 2016 Eirik Vale Aase. All rights reserved.
//

import Foundation
import RealmSwift

class Recording: Object {
    @objc dynamic var id = UUID().uuidString
    @objc dynamic var title = ""
    @objc dynamic var project: Project?
    @objc dynamic var section: Section?
    @objc dynamic var dateRecorded = Date()
    @objc dynamic var fileExtension = ""
    
    override static func primaryKey() -> String? {
        return R.DatabaseKeys.id
    }
}

extension Recording: DatabaseObject {}
extension Recording: AudioPlayable {}

extension Recording: FileSystemObject {
    var url: URL {
        return section!.url
            .appendingPathComponent(id)
            .appendingPathExtension(fileExtension)
    }
}

extension Recording: Comparable {
    static func < (lhs: Recording, rhs: Recording) -> Bool {
        return lhs.title < rhs.title
    }
}

extension String {
    var correspondingRecording: Recording? {
        guard let realm = try? Realm() else { return nil }
        return realm.object(ofType: Recording.self, forPrimaryKey: self)
    }
}
