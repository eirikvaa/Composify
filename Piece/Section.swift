//
//  Section.swift
//  Piece
//
//  Created by Eirik Vale Aase on 10.08.2016.
//  Copyright © 2016 Eirik Vale Aase. All rights reserved.
//

import Foundation
import CoreData

class Section: NSManagedObject {
	static func ==(lhs: Section, rhs: Section) -> Bool {
		return
			lhs.title == rhs.title &&
			lhs.project == rhs.project &&
			lhs.recordings == rhs.recordings
	}
}
