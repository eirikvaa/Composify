//
//  RecordingDao.swift
//  Composify
//
//  Created by Eirik Vale Aase on 13/03/2021.
//  Copyright © 2021 Eirik Vale Aase. All rights reserved.
//

import Foundation
import RealmSwift

protocol RecordingDaoInjectable {
    var recordingDao: RecordingDao { get }
}

extension RecordingDaoInjectable {
    var recordingDao: RecordingDao {
        RecordingDaoImpl()
    }
}

class RecordingDaoInjectableImpl: RecordingDaoInjectable {}

protocol RecordingDao {
    func getRecordings(in section: Section) -> [Recording]
    func save(recording: Recording, to section: Section)
}

class RecordingDaoImpl: RecordingDao {
    func getRecordings(in section: Section) -> [Recording] {
        let realm = try! Realm()
        let recordings = realm
            .objects(Recording.self)
            .filter { $0.section == section }
        return Array(recordings)
    }
    
    func save(recording: Recording, to section: Section) {
        let realm = try! Realm()
        try! realm.write {
            realm.add(recording)
            section.recordings.append(recording)
        }
    }
}
