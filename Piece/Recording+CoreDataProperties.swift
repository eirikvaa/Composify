//
//  Recording+CoreDataProperties.swift
//  Piece
//
//  Created by Eirik Vale Aase on 10.08.2016.
//  Copyright © 2016 Eirik Vale Aase. All rights reserved.
//

import Foundation
import CoreData

extension Recording: FileSystemObject {
	var url: URL {
		return section.url
			.appendingPathComponent(title)
			.appendingPathExtension(fileExtension)
	}
}

extension Recording {
	@NSManaged var title: String
	@NSManaged var dateRecorded: Date
	@NSManaged var project: Project
	@NSManaged var section: Section
	@NSManaged var fileExtension: String
	
	override var description: String {
		return "Recording - title: \(title).\(fileExtension)"
	}
}
