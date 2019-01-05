//
//  Collection+Ext.swift
//  Composify
//
//  Created by Eirik Vale Aase on 15.08.2018.
//  Copyright © 2018 Eirik Vale Aase. All rights reserved.
//

import Foundation

extension Collection {
    /// A happy-path method for checking if a collection consists of at
    /// least one element.
    var hasElements: Bool {
        return isEmpty == false
    }
}
