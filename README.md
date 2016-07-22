# iOS-Swift-Swipe-TableView-Cell-2

**purpose** to have a better user experience when doing actions on items in a list.

**vision** working Swift version of [MCSwipeTableViewCell](https://github.com/alikaragoz/MCSwipeTableViewCell) with up two 4 gestures in each direction (iOS 8+)

**methodology** coded in Swift, import ```SwipeCell.swift``` and ```SwipeCell.xib``` and add this code to your TableViewController

```swift
  // MARK: - SWIPE LOAD CELL
  override func viewDidLoad() {
    super.viewDidLoad()

    // custom cell
    let nib = UINib(nibName: "SwipeCell", bundle: nil)
    tableView.registerNib(nib, forCellReuseIdentifier: "cell")
  }
```

```swift
  // MARK: - SWIPE CONFIGURE CELL
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! SwipeCell
    cell.swipeDelegate = self
    cell.textLabel?.text = items[indexPath.row]

    // change the trigger locations between swipe gestures
//    cell.firstTrigger = 0.25
//    cell.secondTrigger = 0.50
//    cell.thirdTrigger = 0.75
  
    cell.addSwipeGesture(swipeGesture: SwipeCell.SwipeGesture.Right1, swipeMode: SwipeCell.SwipeMode.Slide, icon: UIImageView(image: UIImage(named: "cross")), color: .blueColor()) { (cell) -> () in
    }
    cell.addSwipeGesture(swipeGesture: SwipeCell.SwipeGesture.Right2, swipeMode: SwipeCell.SwipeMode.Bounce, icon: UIImageView(image: UIImage(named: "list")), color: .redColor()) { (cell) -> () in
    }
    cell.addSwipeGesture(swipeGesture: SwipeCell.SwipeGesture.Left1, swipeMode: SwipeCell.SwipeMode.Slide, icon: UIImageView(image: UIImage(named: "check")), color: .purpleColor()) { (cell) -> () in
    }

    return cell
  }
```  

```swift
  // MARK: - SWIPE OPTIONAL DELEGATE METHODS
  override func swipeTableViewCellDidStartSwiping(cell cell: UITableViewCell) {}
  
  override func swipeTableViewCellDidEndSwiping(cell cell: UITableViewCell) {}
  
  override func swipeTableViewCell(cell cell: UITableViewCell, didSwipeWithPercentage percentage: CGFloat) {}
```

**status** working.

![gif](http://i.imgur.com/Xxs98f1.gif)
