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
struct CFileManager {
    
    // MARK: Properties
    let fileManager = FileManager.default
    private var documentDirectory: URL {
		return fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    private var userProjectsDirectory: URL {
        return documentDirectory.appendingPathComponent(FileSystemDirectories.userProjects.rawValue)
    }
    
    /**
     Creates a directory in the file system for a `FileSystemComposifyObject` instance.
     - Parameter object: An object conforming to the `FileSystemComposifyObject` protocol.
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
     Deletes the file or directory of a FileSystemComposifyObject instance.
     - Parameter object: An object conforming to the FileSystemComposifyObject protocol.
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
}
