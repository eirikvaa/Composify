//
//  Project+CoreDataProperties.swift
//  Piece
//
//  Created by Eirik Vale Aase on 10.08.2016.
//  Copyright © 2016 Eirik Vale Aase. All rights reserved.
//

import Foundation
import CoreData

extension Project: Comparable {
    static func ==(lhs: Project, rhs: Project) -> Bool {
        return lhs.title == rhs.title
    }

    static func <(lhs: Project, rhs: Project) -> Bool {
        return lhs.title < rhs.title
    }
}

extension Project: FileSystemObject {
    var url: URL {
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentDirectory
                .appendingPathComponent(FileSystemDirectories.userProjects.rawValue)
                .appendingPathComponent(title)
    }
}

extension Project {
    @NSManaged var title: String
    @NSManaged var sections: Set<Section>
    @NSManaged var recordings: Set<Recording>

    override var description: String {
        return "[Project - Title: \(title) | Section: \(sections.description) | Recordings: \(recordings.description)"
    }

    static func retrieveCoreDataProjects() -> [Project] {
        var projects = [Project]()
        let fetchRequest = Project.fetchRequest() as! NSFetchRequest<Project>
        let sortDescriptor = NSSortDescriptor(key: #keyPath(Project.title), ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]

        do {
            projects = try CoreDataStack.sharedInstance.viewContext.fetch(fetchRequest)
        } catch {
            print(error.localizedDescription)
        }

        return projects
    }
	
	var sortedSections: [Section] {
		return sections.sorted()
	}
	
	var sortedRecordings: [Recording] {
		return recordings.sorted()
	}
}
