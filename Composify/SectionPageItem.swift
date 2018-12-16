//
//  SectionPageItem.swift
//  Composify
//
//  Created by Eirik Vale Aase on 06.12.2018.
//  Copyright © 2018 Eirik Vale Aase. All rights reserved.
//

import Foundation
import Parchment

struct SectionPageItem: PagingItem, Hashable, Comparable {
    var section: Section?

    init(section: Section?) {
        self.section = section
    }

    var hashValue: Int {
        guard section?.isInvalidated == false else { return 0 }
        return section?.title.hashValue ?? 0
    }

    static func == (lhs: SectionPageItem, rhs: SectionPageItem) -> Bool {
        guard lhs.section?.isInvalidated == false else { return false }
        guard rhs.section?.isInvalidated == false else { return false }
        return lhs.section?.index == rhs.section?.index
    }

    static func < (lhs: SectionPageItem, rhs: SectionPageItem) -> Bool {
        return lhs.section?.index ?? 0 < rhs.section?.index ?? 0
    }
}
