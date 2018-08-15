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
        setValue(nil, forKey: Strings.UserDefaults.lastProjectID)
    }
    
    func resetLastSection() {
        setValue(nil, forKey: Strings.UserDefaults.lastSectionID)
    }
    
    var projectStoreID: String? {
        return value(forKey: Strings.UserDefaults.projectStoreID) as? String
    }
}
