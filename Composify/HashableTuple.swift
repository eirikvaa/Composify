//
//  Helpers.swift
//  Composify
//
//  Created by Eirik Vale Aase on 01.10.2017.
//  Copyright © 2017 Eirik Vale Aase. All rights reserved.
//

import UIKit

struct HashableTuple {
    var t: (Int, Int)
    
    init(_ t: (Int, Int)) {
        self.t = t
    }
}

extension HashableTuple: Hashable {
    var hashValue: Int {
        return t.0.hashValue ^ t.1.hashValue
    }
}

extension HashableTuple: Equatable {
    static func == (lhs: HashableTuple, rhs: HashableTuple) -> Bool {
        return lhs.t == rhs.t
    }
}

extension HashableTuple: CustomStringConvertible {
    var description: String {
        return "(\(t.0), \(t.1))"
    }
}
