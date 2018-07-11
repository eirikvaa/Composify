//
//  Recording.swift
//  Composify
//
//  Created by Eirik Vale Aase on 10.08.2016.
//  Copyright © 2016 Eirik Vale Aase. All rights reserved.
//

import Foundation
import RealmSwift
import AVFoundation

class Recording: Object {
    @objc dynamic var id = UUID().uuidString
    @objc dynamic var title = ""
    @objc dynamic var project: Project?
    @objc dynamic var section: Section?
    @objc dynamic var dateRecorded = Date()
    @objc dynamic var fileExtension = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

extension Recording: FileSystemObject {
    var url: URL {
        return section!.url
            .appendingPathComponent(id)
            .appendingPathExtension(fileExtension)
    }
}

extension Recording {
    var duration: Float64 {
        let audioAsset = AVURLAsset(url: url)
        let assetDuration = audioAsset.duration
        return CMTimeGetSeconds(assetDuration)
    }
}

extension Recording: Comparable {
    static func < (lhs: Recording, rhs: Recording) -> Bool {
        return lhs.title < rhs.title
    }
}

extension String {
    var correspondingRecording: Recording? {
        return RealmStore.shared.realm.object(ofType: Recording.self, forPrimaryKey: self)
    }
}
