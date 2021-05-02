//
//  Date+Extensions.swift
//  Composify
//
//  Created by Eirik Vale Aase on 02/05/2021.
//  Copyright © 2021 Eirik Vale Aase. All rights reserved.
//

import Foundation

extension Date {
    var prettyDate: String {
        let createdAtDate = self
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: createdAtDate)
    }
}
