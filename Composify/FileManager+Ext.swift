//
//  PIEFileManager.swift
//  Composify
//
//  Created by Eirik Vale Aase on 24.07.2016.
//  Copyright © 2016 Eirik Vale Aase. All rights reserved.
//

import Foundation

/**
The `FileSystemObject` protocol gives information about where a `FileSystemComposifyObject` instance is in the file system.
- Author: Eirik Vale Aase
*/
protocol FileSystemObject {
	var url: URL { get }
}

extension FileSystemObject {
    func getTitle() -> String? {
        switch self {
        case let project as Project:
            return project.title
        case let section as Section:
            return section.title
        case let recording as Recording:
            return recording.title
        default:
            break
        }
        
        return nil
    }
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

enum FileManagerError: Error {
    case unableToSaveObject(object: FileSystemObject)
    case unableToDeleteObject(object: FileSystemObject)
}

/**
A class for saving, deleting and renaming projects, sections and recordings in the file system.
- Author: Eirik Vale Aase
*/
extension FileManager {
    
    /**
     Creates a directory in the file system for a `FileSystemComposifyObject` instance.
     - Parameter object: An object conforming to the `FileSystemComposifyObject` protocol.
    */
    func save<T: FileSystemObject>(_ object: T) throws {
		// The AudioRecorder will create the audio file.
		if object is Project || object is Section {
			do {
				try createDirectory(at: object.url, withIntermediateDirectories: true, attributes: nil)
			} catch {
				throw FileManagerError.unableToSaveObject(object: object)
			}
		}
    }
    
    /**
     Deletes the file or directory of a FileSystemComposifyObject instance.
     - Parameter object: An object conforming to the FileSystemComposifyObject protocol.
    */
    func delete<T: FileSystemObject>(_ object: T) throws {
		let url = object.url
		
		do {
			if fileExists(atPath: url.path) {
				try removeItem(at: url)
			}
		} catch {
            throw FileManagerError.unableToDeleteObject(object: object)
		}
    }
}
