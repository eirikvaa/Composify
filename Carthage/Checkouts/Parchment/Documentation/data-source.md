# Using the data source

Let’s start by defining an array that contains the information we need to display our menu items:

```Swift
class ViewController: UIViewController {
    let cities = [
        "Oslo",
        "Stockholm",
        "Tokyo",
        "Barcelona",
        "Vancouver",
        "Berlin"
    ]
}
```

Then we initialize our `PagingViewController`:

```Swift
class ViewController: UIViewController {
    ...
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let pagingViewController = PagingViewController<PagingIndexItem>()
        pagingViewController.dataSource = self
    }
}
```

Here we need to specify the generic `PagingItem` type. `PagingItem` is just an empty protocol that is used to generate the menu items without having to allocate the view controllers. The only requirement is that the type conforms to `Hashable` and `Comparable`. Since we’re just going to display a title in the menu items we’re just using  `PagingIndexItem`, which is one of the default types provided by Parchment. 

In our data source implementation we set the number of view controllers equal to the number of items in our cities array, and return an instance of `PagingIndexItem` with the title of each city:

```Swift
extension ViewController: PagingViewControllerDataSource {
    func numberOfViewControllers<T>(in pagingViewController: PagingViewController<T>) -> Int {
        return cities.count
    }

    func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, pagingItemForIndex index: Int) -> T {
        return PagingIndexItem(index: index, title: cities[index]) as! T
    }

    func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, viewControllerForIndex index: Int) -> UIViewController {
        return CityViewController(city: cities[index])
    }
}
```

The `viewControllerForIndex` method will only be called for the currently selected item and any of its siblings. This means that we only allocate the view controllers that are actually needed at any given point.

Parchment will automatically set the first item as selected, but if you want to select another you can do it like this:

```Swift
pagingViewController.select(index: 3)
```

This can be called both before and after the view has appeared.

_Check out the DelegateExample target for more details._