//
//  Section+CoreDataProperties.swift
//  Piece
//
//  Created by Eirik Vale Aase on 10.08.2016.
//  Copyright © 2016 Eirik Vale Aase. All rights reserved.
//

import Foundation
import CoreData

extension Section: FileSystemObject {
	var url: URL {
		return project.url.appendingPathComponent(title)
	}
}

extension Section {
	@NSManaged var title: String
	@NSManaged var project: Project
	@NSManaged var recordings: Set<Recording>
	
	override var description: String {
		return "Section - title: \(title)"
	}
}
