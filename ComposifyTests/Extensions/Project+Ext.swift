//
//  Project+Ext.swift
//  ComposifyTests
//
//  Created by Eirik Vale Aase on 10/12/2019.
//  Copyright © 2019 Eirik Vale Aase. All rights reserved.
//

@testable import Composify
import Foundation

extension Project {
    static func createProject(populateWithSectionCount count: Int = 0) -> Project? {
        let project = Project()
        RealmRepository().save(object: project)

        for i in 0 ..< count {
            let section = Section()
            section.title = "S\(i)"
            section.index = i

            RealmRepository().save(object: section)
            RealmRepository().performOperation { _ in
                project.sections.append(section)
            }
        }

        return project
    }
}
