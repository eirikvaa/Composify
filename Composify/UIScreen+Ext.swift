//
//  UIScreen+Ext.swift
//  Composify
//
//  Created by Eirik Vale Aase on 16.08.2018.
//  Copyright © 2018 Eirik Vale Aase. All rights reserved.
//

import UIKit

extension UIScreen {
    var isSmall: Bool {
        return UIScreen.main.bounds.width <= 320
    }
}
