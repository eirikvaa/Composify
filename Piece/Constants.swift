//
//  Constants.swift
//  Piece
//
//  Created by Eirik Vale Aase on 24.05.2017.
//  Copyright © 2017 Eirik Vale Aase. All rights reserved.
//

import UIKit

struct Colors {
	static let red = UIColor(red: 0.91, green: 0.40, blue: 0.36, alpha: 1.00)
    static let edit = UIColor(red: 68.0 / 255.0, green: 108.0 / 255.0, blue: 179.0 / 255.0, alpha: 1.0)
    static let delete = UIColor(red: 231.0 / 255.0, green: 76.0 / 255.0, blue: 60.0 / 255.0, alpha: 1.0)
}

struct Images {
    static let play = UIImage(named: Strings.Images.play)
    static let pause = UIImage(named: Strings.Images.pause)
}

struct Strings {
    struct Cells {
        static let projectCell = "ProjectCell"
        static let sectionCell = "SectionCell"
        static let recordingCell = "RecordingCell"
    }
    
    struct CoreData {
        static let projectEntity = "Project"
        static let sectionEntity = "Section"
        static let recordingEntity = "Recording"
        static let modelName = "Piece"
    }
    
    struct KeyValues {
        static let view = "view"
    }
    
    struct StoryboardIDs {
        static let contentPageViewController = "contentPageViewController"
    }
    
    struct Images {
        static let play = "Play"
        static let pause = "Pause"
    }
}
