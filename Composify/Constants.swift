//
//  Constants.swift
//  Composify
//
//  Created by Eirik Vale Aase on 24.05.2017.
//  Copyright © 2017 Eirik Vale Aase. All rights reserved.
//

import UIKit

struct Colors {
	static let mainColor = UIColor(red: 0.20, green: 0.51, blue: 0.71, alpha: 1.00)
    static let secondaryColor = UIColor(red: 0.94, green: 0.62, blue: 0.17, alpha: 1.00)
    static let edit = Colors.mainColor
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
        static let deleteCell = "DeleteCell"
        static let cell = "Cell"
        static let administerCell = "AdministerCell"
    }
    
    struct CoreData {
        static let projectEntity = "Project"
        static let sectionEntity = "Section"
        static let recordingEntity = "Recording"
        static let modelName = "Composify"
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
