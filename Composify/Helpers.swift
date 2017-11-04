//
//  Helpers.swift
//  Composify
//
//  Created by Eirik Vale Aase on 01.10.2017.
//  Copyright © 2017 Eirik Vale Aase. All rights reserved.
//

import UIKit

extension UIFont {
    static func preferredBoldFont(for style: UIFontTextStyle) -> UIFont  {
        let font = UIFont.preferredFont(forTextStyle: style)
        let fontDescriptor = font.fontDescriptor.withSymbolicTraits(.traitBold)
        return UIFont(descriptor: fontDescriptor!, size: 0)
    }
}
