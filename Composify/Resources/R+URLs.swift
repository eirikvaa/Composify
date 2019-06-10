//
//  R+URLs.swift
//  Composify
//
//  Created by Eirik Vale Aase on 22/12/2018.
//  Copyright © 2018 Eirik Vale Aase. All rights reserved.
//

import Foundation

extension R.URLs {
    static var recordingsDirectory: URL {
        let recordings = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first!
            .appendingPathComponent("Recordings", isDirectory: true)
        return recordings
    }
}
