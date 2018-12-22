//
//  UIColor+Ext.swift
//  Composify
//
//  Created by Eirik Vale Aase on 14/12/2018.
//  Copyright © 2018 Eirik Vale Aase. All rights reserved.
//

import UIKit

extension UIColor {
    func components() -> (CGFloat, CGFloat, CGFloat, CGFloat) {
        guard let components = cgColor.components else { return (0, 0, 0, 1) }
        if cgColor.numberOfComponents == 2 {
            return (components[0], components[0], components[0], components[1])
        } else {
            return (components[0], components[1], components[2], components[3])
        }
    }

    static func interpolate(from: UIColor, to: UIColor, with fraction: CGFloat) -> UIColor {
        let minimumFraction = min(1, max(0, fraction))
        let fromComponenets = from.components()
        let toComponents = to.components()
        let red = fromComponenets.0 + (toComponents.0 - fromComponenets.0) * minimumFraction
        let green = fromComponenets.1 + (toComponents.1 - fromComponenets.1) * minimumFraction
        let blue = fromComponenets.2 + (toComponents.2 - fromComponenets.2) * minimumFraction
        let alpha = fromComponenets.3 + (toComponents.3 - fromComponenets.3) * minimumFraction
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}
