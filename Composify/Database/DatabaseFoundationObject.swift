//
//  DatabaseFoundationObject.swift
//  Composify
//
//  Created by Eirik Vale Aase on 16/12/2018.
//  Copyright © 2018 Eirik Vale Aase. All rights reserved.
//

import Foundation

/// A special object that is implemented by the object that loads
/// stuff. For example, with the RealmDatabaseService, this is the
/// ProjectStore object, because it has a reference to all project
/// identification numbers.
protocol DatabaseFoundationObject {
    var identification: String { get }
    var projectIDs: [String] { get set }
}
