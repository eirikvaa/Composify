//
//  PIEFileManager.swift
//  Composify
//
//  Created by Eirik Vale Aase on 24.07.2016.
//  Copyright © 2016 Eirik Vale Aase. All rights reserved.
//

import Foundation

extension FileManager {
    /// Create the recordings directory that recordings are written to if it is needed.
    func createRecordingsDirectoryIfNeeded() {
        let url = R.URLs.recordingsDirectory
        guard !fileExists(atPath: url.path) else { return }

        // Only create the directory if it doesn't exists
        try? createDirectory(at: url, withIntermediateDirectories: true)
    }
}
