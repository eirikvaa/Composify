//
//  Recording+CoreDataProperties.swift
//  Piece
//
//  Created by Eirik Vale Aase on 10.08.2016.
//  Copyright © 2016 Eirik Vale Aase. All rights reserved.
//

import Foundation
import CoreData
import AVFoundation

extension Recording: Comparable {
	static func ==(lhs: Recording, rhs: Recording) -> Bool {
		return lhs.title == rhs.title
	}
	
	static func <(lhs: Recording, rhs: Recording) -> Bool {
		return lhs.title < rhs.title
	}
}

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
	
	var duration: Float64 {
		let audioAsset = AVURLAsset(url: url)
		let assetDuration = audioAsset.duration
		return CMTimeGetSeconds(assetDuration)
	}
}
