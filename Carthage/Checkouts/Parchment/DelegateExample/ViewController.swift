import UIKit
import Parchment

class ViewController: UIViewController {
  
  // Let's start by creating an array of citites that we
  // will use to generate some view controllers.
  fileprivate let cities = [
    "Oslo",
    "Stockholm",
    "Tokyo",
    "Barcelona",
    "Vancouver",
    "Berlin",
    "Shanghai",
    "London",
    "Paris",
    "Chicago",
    "Madrid",
    "Munich",
    "Toronto",
    "Sydney",
    "Melbourne"
  ]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let pagingViewController = PagingViewController<PagingIndexItem>()
    pagingViewController.dataSource = self
    pagingViewController.delegate = self
    
    // Add the paging view controller as a child view controller and
    // contrain it to all edges.
    addChild(pagingViewController)
    view.addSubview(pagingViewController.view)
    view.constrainToEdges(pagingViewController.view)
    pagingViewController.didMove(toParent: self)
  }
  
}

extension ViewController: PagingViewControllerDataSource {
  
  func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, pagingItemForIndex index: Int) -> T {
    return PagingIndexItem(index: index, title: cities[index]) as! T
  }
  
  func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, viewControllerForIndex index: Int) -> UIViewController {
    return CityViewController(title: cities[index])
  }
  
  func numberOfViewControllers<T>(in: PagingViewController<T>) -> Int {
    return cities.count
  }
  
}

extension ViewController: PagingViewControllerDelegate {
  
  // We want the size of our paging items to equal the width of the
  // city title. Parchment does not support self-sizing cells at
  // the moment, so we have to handle the calculation ourself. We
  // can access the title string by casting the paging item to a
  // PagingTitleItem, which is the PagingItem type used by
  // FixedPagingViewController.
  func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, widthForPagingItem pagingItem: T, isSelected: Bool) -> CGFloat? {
    guard let item = pagingItem as? PagingIndexItem else { return 0 }

    let insets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    let size = CGSize(width: CGFloat.greatestFiniteMagnitude, height: pagingViewController.menuItemSize.height)
    let attributes = [NSAttributedString.Key.font: pagingViewController.font]
    
    let rect = item.title.boundingRect(with: size,
      options: .usesLineFragmentOrigin,
      attributes: attributes,
      context: nil)

    let width = ceil(rect.width) + insets.left + insets.right
    
    if isSelected {
      return width * 1.5
    } else {
      return width
    }
  }
  
}
