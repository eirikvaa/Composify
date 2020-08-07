//
//  String+Ext.swift
//  Composify
//
//  Created by Eirik Vale Aase on 15.08.2018.
//  Copyright © 2018 Eirik Vale Aase. All rights reserved.
//

import Foundation

extension String {
    /// A happy-path method for checking if a string consists of at
    /// least one character.
    var hasPositiveCharacterCount: Bool {
        !isEmpty
    }
}
