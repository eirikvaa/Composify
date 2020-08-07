import Foundation
@testable import Parchment

struct Item: PagingItem, Hashable, Comparable {
  let index: Int
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(index)
  }
}

func ==(lhs: Item, rhs: Item) -> Bool {
  return lhs.index == rhs.index
}

func <(lhs: Item, rhs: Item) -> Bool {
  return lhs.index < rhs.index
}
