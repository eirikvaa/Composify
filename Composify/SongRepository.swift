//
//  SongRepository.swift
//  Composify
//
//  Created by Eirik Vale Aase on 13/03/2021.
//  Copyright © 2021 Eirik Vale Aase. All rights reserved.
//

import Foundation

protocol SongRepositoryInjectable {
    var songRepository: SongRepository { get }
}

extension SongRepositoryInjectable {
    var songRepository: SongRepository {
        SongRepositoryImpl()
    }
}

protocol SongRepository {
    func getRecordings(in section: Section) -> [Recording]
}

class SongRepositoryImpl: SongRepository, RecordingDaoInjectable {
    func getRecordings(in section: Section) -> [Recording] {
        recordingDao.getRecordings(in: section)
    }
}
