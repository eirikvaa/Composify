//
//  Date+Ext.swift
//  Composify
//
//  Created by Eirik Vale Aase on 18/08/2020.
//  Copyright © 2020 Eirik Vale Aase. All rights reserved.
//

import Foundation

extension Date {
    func shortHumanReadableDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, d MMM yyyy HH:mm:ss"
        return dateFormatter.string(from: self)
    }
}
