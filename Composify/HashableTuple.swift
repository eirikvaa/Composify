//
//  Helpers.swift
//  Composify
//
//  Created by Eirik Vale Aase on 01.10.2017.
//  Copyright © 2017 Eirik Vale Aase. All rights reserved.
//

import UIKit

struct HashableTuple<T: Equatable & Hashable> {
    var t: (first: T, second: T)

    init(_ first: T, _ second: T) {
        t.0 = first
        t.1 = second
    }

    var first: T {
        return t.first
    }

    var second: T {
        return t.second
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
        let first = t.0
        let second = t.1
        return "(\(first), \(second))"
    }
}
