//
//  Realm.swift
//  Piece
//
//  Created by Eirik Vale Aase on 15.10.2017.
//  Copyright © 2017 Eirik Vale Aase. All rights reserved.
//

import Foundation
import AVFoundation
import RealmSwift

extension Project: Comparable {
    static func ==(lhs: Project, rhs: Project) -> Bool {
        return lhs.title == rhs.title
    }
    
    public static func <(lhs: Project, rhs: Project) -> Bool {
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

class Project: Object {
    @objc dynamic var title = ""
    
    let sections = List<Section>()
    let recordings = List<Recording>()
    
    var sortedSections: [Section] {
        return sections.sorted(by: {$0.title < $1.title})
    }
    
    var sortedRecordings: [Recording] {
        return recordings.sorted(by: {$0.title < $1.title})
    }
}

class Section: Object {
    @objc dynamic var title = ""
    
    @objc dynamic var project: Project?
    
    let recordings = List<Recording>()
    
    var sortedRecordings: [Recording] {
        return recordings.sorted(by: {$0.title < $1.title})
    }
}

extension Section: Comparable {
    static func ==(lhs: Section, rhs: Section) -> Bool {
        return lhs.title == rhs.title
    }
    
    public static func <(lhs: Section, rhs: Section) -> Bool {
        return lhs.title < rhs.title
    }
}

extension Section: FileSystemObject {
    var url: URL {
        return project!.url.appendingPathComponent(title)
    }
}

class Recording: Object {
    @objc dynamic var title = ""
    
    @objc dynamic var project: Project?
    @objc dynamic var section: Section?
    @objc dynamic var fileExtension = ""
    
    var duration: Float64 {
        let audioAsset = AVURLAsset(url: url)
        let assetDuration = audioAsset.duration
        return CMTimeGetSeconds(assetDuration)
    }
}

extension Recording: Comparable {
    static func ==(lhs: Recording, rhs: Recording) -> Bool {
        return lhs.title == rhs.title
    }
    
    public static func <(lhs: Recording, rhs: Recording) -> Bool {
        return lhs.title < rhs.title
    }
}

extension Recording: FileSystemObject {
    var url: URL {
        return section!.url
            .appendingPathComponent(title)
            .appendingPathExtension(fileExtension)
    }
}
