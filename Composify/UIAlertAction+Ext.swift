//
//  UIAlertAction+Ext.swift
//  Composify
//
//  Created by Eirik Vale Aase on 05/01/2019.
//  Copyright © 2019 Eirik Vale Aase. All rights reserved.
//

import UIKit

extension UIAlertAction {
    static var cancelAction: UIAlertAction {
        UIAlertAction(title: R.Loc.cancel, style: .cancel)
    }
}
