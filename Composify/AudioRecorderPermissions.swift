//
//  AudioRecorderPermissions.swift
//  Composify
//
//  Created by Eirik Vale Aase on 07/08/2020.
//  Copyright © 2020 Eirik Vale Aase. All rights reserved.
//

import Foundation
import AVFoundation

struct AudioRecorderPermissions {
    /// Ask the user for permissions to use the microphone
    /// - Parameters:
    ///     - completion: Callback when user granted or denied access to microphone
    ///     - granted: Whether or not the user granted access to the microphone
    static func askForMicrophonePermissions(completion: @escaping (_ granted: Bool) -> Void) {
        let session = AVAudioSession.sharedInstance()
        let permission = session.recordPermission
        
        if case .undetermined = permission {
            session.requestRecordPermission { granted in
                completion(granted)
                return
            }
        }
        
        completion(permission == .granted)
    }
}
