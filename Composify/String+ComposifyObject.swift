//
//  String+ComposifyObject.swift
//  Composify
//
//  Created by Eirik Vale Aase on 19/12/2018.
//  Copyright © 2018 Eirik Vale Aase. All rights reserved.
//

import Foundation
import RealmSwift

extension String {
    func composifyObject<T: ComposifyObject>() -> T? {
        guard let realm = try? Realm() else { return nil }

        if let obj = realm.object(ofType: Project.self, forPrimaryKey: self) {
            return obj as? T
        }

        if let obj = realm.object(ofType: Section.self, forPrimaryKey: self) {
            return obj as? T
        }

        if let obj = realm.object(ofType: Recording.self, forPrimaryKey: self) {
            return obj as? T
        }

        return nil
    }
}
