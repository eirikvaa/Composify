//
//  PIEFileManager.swift
//  Composify
//
//  Created by Eirik Vale Aase on 24.07.2016.
//  Copyright © 2016 Eirik Vale Aase. All rights reserved.
//

import Foundation

extension FileManager {
    func createRecordingsDirectoryIfNeeded() {
        let recordingsDirectoryURL = R.URLs.recordingsDirectory

        if fileExists(atPath: recordingsDirectoryURL.path).isFalse {
            try? createDirectory(at: recordingsDirectoryURL, withIntermediateDirectories: true)
        }
    }
}
