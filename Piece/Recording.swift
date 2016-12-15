//
//  Recording.swift
//  Piece
//
//  Created by Eirik Vale Aase on 10.08.2016.
//  Copyright © 2016 Eirik Vale Aase. All rights reserved.
//

import Foundation
import CoreData

class Recording: NSManagedObject {
	convenience init?(with title: String, section: Section, project: Project, fileExtension: FileSystemExtensions, insertIntoManagedObjectContext context: NSManagedObjectContext!) {
		let entity = NSEntityDescription.entity(forEntityName: "Recording", in: context)!
		self.init(entity: entity, insertInto: context)
		
		self.title = title
		self.section = section
		self.project = project
		self.fileExtension = fileExtension.rawValue
		self.dateRecorded = Date()
	}
}
