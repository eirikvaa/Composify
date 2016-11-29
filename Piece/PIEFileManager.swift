//
//  PIEFileManager.swift
//  Piece
//
//  Created by Eirik Vale Aase on 24.07.2016.
//  Copyright © 2016 Eirik Vale Aase. All rights reserved.
//

import Foundation

/**
The `FileSystemObject` protocol gives information about where a `FileSystemPieceObject` instance is in the file system.
- Author: Eirik Vale Aase
*/
protocol FileSystemObject {
	var url: URL { get }
}

/**
An enum containing important directories in the `FileSystemObject` hierarchy.
- Author: Eirik Vale Aase
*/
enum FileSystemDirectories: String {
	case userProjects = "User Projects"
}

/**
An enum consisting of file extensions.
- Author: Eirik Vale Aase
*/
enum FileSystemExtensions: String {
	case caf
}

/**
A class for saving, deleting and renaming projects, sections and recordings in the file system.
- Author: Eirik Vale Aase
*/
struct PIEFileManager {
    
    // MARK: Properties
    let fileManager = FileManager.default
    private var documentDirectory: URL {
		return fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    private var userProjectsDirectory: URL {
        return documentDirectory.appendingPathComponent(FileSystemDirectories.userProjects.rawValue)
    }
    
    /**
     Creates a directory in the file system for a `FileSystemPieceObject` instance.
     - Parameter object: An object conforming to the `FileSystemPieceObject` protocol.
    */
    func save<T: Any>(_ object: T) where T: FileSystemObject {
		// The AudioRecorder will create the audio file.
		if object is Project || object is Section {
			do {
				try fileManager.createDirectory(at: object.url, withIntermediateDirectories: true, attributes: nil)
			} catch {
				print(error)
			}
		}
    }
    
    /**
     Deletes the file or directory of a FileSystemPieceObject instance.
     - Parameter object: An object conforming to the FileSystemPieceObject protocol.
    */
    func delete<T: Any>(_ object: T) where T: FileSystemObject {
		let url = object.url
		
		do {
			if fileManager.fileExists(atPath: url.path) {
				try fileManager.removeItem(at: url)
			}
		} catch {
			print(error)
		}
    }
    
    /**
     Renames a FileSystemPieceObject isntance.
     - Parameters:
        - object: An object conforming to the FileSystemPieceObject protocol.
        - from: the old title.
        - to: the new title.
		- section: new section
		- project: new project
    */
	func rename<T: Any>(_ object: T, from: String, to new: String, section: Section?, project: Project?) where T: FileSystemObject {
		let source = object.url
		var destination: URL!
		
		switch object {
		case _ as Project, _ as Section:
			destination = object.url
				.deletingLastPathComponent()
				.appendingPathComponent(new)
		case let recording as Recording:
			destination = object.url
				.deletingPathExtension()		// deletes caf
				.deletingLastPathComponent()	// deletes title
				.deletingLastPathComponent()	// deletes section
				.deletingLastPathComponent()	// deletes project
			
			// If the user picks another project than it was originally recorded in, this changes that.
			if let section = section, let project = project {
				destination = destination
					.appendingPathComponent(project.title)
					.appendingPathComponent(section.title)
			} else {
				destination = destination
					.appendingPathComponent(recording.project.title)
					.appendingPathComponent(recording.section.title)
			}
			
			destination = destination
				.appendingPathComponent(new)
				.appendingPathExtension(recording.fileExtension)
			
		default:
			break
		}
		
		do {
			try fileManager.moveItem(at: source, to: destination)
		} catch {
			print(error)
		}
	}
	
	/**
	Removes the "User Projects" directory.
	*/
	func reset() {
		do {
			try fileManager.removeItem(at: userProjectsDirectory)
		} catch {
			print(error.localizedDescription)
		}
	}

}
