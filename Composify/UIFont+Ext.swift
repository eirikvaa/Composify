//
//  UIFont+Ext.swift
//  Composify
//
//  Created by Eirik Vale Aase on 15.08.2018.
//  Copyright © 2018 Eirik Vale Aase. All rights reserved.
//

import UIKit

extension UIFont {
    static func preferredBoldFont(for style: UIFontTextStyle) -> UIFont {
        let font = UIFont.preferredFont(forTextStyle: style)
        let fontDescriptor = font.fontDescriptor.withSymbolicTraits(.traitBold)
        return UIFont(descriptor: fontDescriptor!, size: 0)
    }
}
