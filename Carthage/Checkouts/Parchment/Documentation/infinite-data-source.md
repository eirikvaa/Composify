# Using the infinite data source

If you’re creating something like a calendar, the number of view controllers can be infinitely large, or maybe you don’t know exactly how many items you need to display since you’re fetching them from the server as you are scrolling. In these cases you can use the  `PagingViewControllerInfiniteDataSource` protocol. 

## Calendar example

Let’s look at how you can create your own calendar data source. This is what we want to achieve:

![](https://s3-us-west-1.amazonaws.com/parchment-swift/parchment-calendar.gif "Calendar Example")

The first thing we need to do is create our own `PagingItem` to hold our dates. `PagingItem` is just an empty protocol that is used to generate menu items for all the view controllers, without having to actually allocate them before they are needed. You can store whatever data that makes the most sense for your application, the only requirement is that it needs to conform to `Hashable` and `Comparable`.

```Swift
struct CalendarItem: PagingItem, Hashable, Comparable {
  let date: Date
  
  init(date: Date) {
    self.date = date
  }
  
  var hashValue: Int {
    return date.hashValue
  }
  
  static func ==(lhs: CalendarItem, rhs: CalendarItem) -> Bool {
    return lhs.date == rhs.date
  }
  
  static func <(lhs: CalendarItem, rhs: CalendarItem) -> Bool {
    return lhs.date < rhs.date
  }
}
```

Now that we have our custom `PagingItem`, we can create our `PagingViewController` instance where we specify `CalendarItem` as the generic type: 

```Swift
class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let pagingViewController = PagingViewController<CalendarItem>()
    }
```

Then we need to conform to the `PagingViewControllerInfiniteDataSource` protocol:

```Swift
extension ViewController: PagingViewControllerInfiniteDataSource {
  func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, viewControllerForPagingItem pagingItem: T) -> UIViewController {
    let calendarItem = pagingItem as! CalendarItem
    return CalendarViewController(date: calendarItem.date)
  }
  
  func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, pagingItemBeforePagingItem pagingItem: T) -> T? {
    let calendarItem = pagingItem as! CalendarItem
    return CalendarItem(date: calendarItem.date.addingTimeInterval(-86400)) as? T
  }
  
  func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, pagingItemAfterPagingItem pagingItem: T) -> T? {
    let calendarItem = pagingItem as! CalendarItem
    return CalendarItem(date: calendarItem.date.addingTimeInterval(86400)) as? T
  } 
}
```
  
Every time `pagingItemBeforePagingItem:` or `pagingItemAfterPagingItem:` is called, we either subtract or append the time interval equal to one day. This means our paging view controller will show one menu item for each day.

We then set our `infiniteDataSource` property and select our initial item. In this example, we want the current date to be the initially selected:

```Swift
pagingViewController.infiniteDataSource = self
pagingViewController.select(pagingItem: CalendarItem(date: Date()))
```

Finally, we add `pagingViewController` as a child view controller and setup the constraints for the view:

```Swift
addChildViewController(pagingViewController)
view.addSubview(pagingViewController.view)
pagingViewController.didMove(toParentViewController: self)
pagingViewController.view.translatesAutoresizingMaskIntoConstraints = false

NSLayoutConstraint.activate([
  pagingViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
  pagingViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
  pagingViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
  pagingViewController.view.topAnchor.constraint(equalTo: view.topAnchor)
])
```

_Check out the Calendar example target for more details_
