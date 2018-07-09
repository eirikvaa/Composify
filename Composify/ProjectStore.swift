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
    var projectIDs = List<String>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
