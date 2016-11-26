//
//  Project.swift
//  Piece
//
//  Created by Eirik Vale Aase on 10.08.2016.
//  Copyright © 2016 Eirik Vale Aase. All rights reserved.
//

import Foundation
import CoreData

class Project: NSManagedObject {
	static func ==(lhs: Project, rhs: Project) -> Bool {
		return
			lhs.title == rhs.title &&
			lhs.sections == rhs.sections &&
			lhs.recordings == rhs.recordings
	}
}
