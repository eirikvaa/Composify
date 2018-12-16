//
//  UserDefaults+Ext.swift
//  Composify
//
//  Created by Eirik Vale Aase on 15.08.2018.
//  Copyright © 2018 Eirik Vale Aase. All rights reserved.
//

import Foundation

extension UserDefaults {
    func resetLastProject() {
        setValue(nil, forKey: R.UserDefaults.lastProjectID)
    }

    func resetLastSection() {
        setValue(nil, forKey: R.UserDefaults.lastSectionID)
    }

    var projectStoreID: String? {
        return value(forKey: R.UserDefaults.projectStoreID) as? String
    }
}
