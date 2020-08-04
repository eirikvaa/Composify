import UIKit
import Parchment

struct IconItem: PagingItem, Hashable, Comparable {
  
  let icon: String
  let index: Int
  let image: UIImage?
  
  init(icon: String, index: Int) {
    self.icon = icon
    self.index = index
    self.image = UIImage(named: icon)
  }
  
  var hashValue: Int {
    return icon.hashValue
  }
  
  static func <(lhs: IconItem, rhs: IconItem) -> Bool {
    return lhs.index < rhs.index
  }
  
  static func ==(lhs: IconItem, rhs: IconItem) -> Bool {
    return (
      lhs.index == rhs.index &&
      lhs.icon == rhs.icon
    )
  }
}

class ViewController: UIViewController {
  
  // Let's start by creating an array of icon names that
  // we will use to generate some view controllers.
  fileprivate let icons = [
    "compass",
    "cloud",
    "bonnet",
    "axe",
    "earth",
    "knife",
    "leave",
    "light",
    "map",
    "moon",
    "mushroom",
    "shoes",
    "snow",
    "star",
    "sun",
    "tipi",
    "tree",
    "water",
    "wind",
    "wood"
  ]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let pagingViewController = PagingViewController<IconItem>()
	pagingViewController.menuItemSource = .class(type: IconPagingCell.self)
    pagingViewController.menuItemSize = .fixed(width: 60, height: 60)
    pagingViewController.textColor = UIColor(red: 0.51, green: 0.54, blue: 0.56, alpha: 1)
    pagingViewController.selectedTextColor = UIColor(red: 0.14, green: 0.77, blue: 0.85, alpha: 1)
    pagingViewController.indicatorColor = UIColor(red: 0.14, green: 0.77, blue: 0.85, alpha: 1)
    pagingViewController.dataSource = self
    pagingViewController.select(pagingItem: IconItem(icon: icons[0], index: 0))
    
    // Add the paging view controller as a child view controller
    // and contrain it to all edges.
    addChild(pagingViewController)
    view.addSubview(pagingViewController.view)
    view.constrainToEdges(pagingViewController.view)
    pagingViewController.didMove(toParent: self)
  }
  
}

extension ViewController: PagingViewControllerDataSource {
  
  func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, viewControllerForIndex index: Int) -> UIViewController {
    return IconViewController(title: icons[index].capitalized)
  }
  
  func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, pagingItemForIndex index: Int) -> T {
    return IconItem(icon: icons[index], index: index) as! T
  }
  
  func numberOfViewControllers<T>(in: PagingViewController<T>) -> Int {
    return icons.count
  }
  
}
