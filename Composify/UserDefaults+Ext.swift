//
//  UserDefaults+Ext.swift
//  Composify
//
//  Created by Eirik Vale Aase on 15.08.2018.
//  Copyright © 2018 Eirik Vale Aase. All rights reserved.
//

import Foundation

extension UserDefaults {
    /// Reset the previously shown project, for example when the project is deleted
    func resetLastProject() {
        setValue(nil, forKey: R.UserDefaults.lastProjectID)
    }

    /// Reset the previously shown section, for example when the section is deleted
    func resetLastSection() {
        setValue(nil, forKey: R.UserDefaults.lastSectionID)
    }

    func fetchLastProjectID() -> String? {
        return string(forKey: R.UserDefaults.lastProjectID)
    }
}
