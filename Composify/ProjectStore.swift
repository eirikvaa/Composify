//
//  ProjectStore.swift
//  Composify
//
//  Created by Eirik Vale Aase on 10.07.2018.
//  Copyright © 2018 Eirik Vale Aase. All rights reserved.
//

import Foundation
import RealmSwift

final class ProjectStore: Object {
    @objc dynamic var id = UUID().uuidString
    var _projectIDs = List<String>()
    
    override static func primaryKey() -> String? {
        return R.DatabaseKeys.id
    }
}

extension ProjectStore: DatabaseObject, DatabaseFoundationObject {
    var projectIDs: [String] {
        get {
            return Array(_projectIDs)
        }
        set {
            _projectIDs.removeAll()
            newValue.forEach { _projectIDs.append($0) }
        }
    }
    
    var identification: String {
        return id
    }
}
