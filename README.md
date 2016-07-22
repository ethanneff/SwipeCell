# Swipe Cell

**purpose** to have a better user experience when doing actions on items in a list.

**vision** working Swift version of [MCSwipeTableViewCell](https://github.com/alikaragoz/MCSwipeTableViewCell) with up to 4 gestures in each direction (iOS 8+)

**methodology** coded in Swift, import ```SwipeCell.swift``` and ```SwipeCell.xib``` and add this code to your TableViewController

```swift
class TableViewCell: UITableViewCell {
  // MARK: - add swipe properties to your UITableViewCell
  private var swipe: SwipeCell!
  weak var swipeDelegate: SwipeCompleteDelegate?
}
```

```swift
  // MARK: - setup swipe on UITableViewCell init
  func setupSwipe() {
    // add the swipe feature
    swipe = SwipeCell(cell: self)
    
    // optional swipe delegate (see functions below)
    swipe.delegate = self
    
    // set the starting positions for the swipe buttons (up to 4 on each side)
    swipe.firstTrigger = 0.15
    swipe.secondTrigger = 0.40
    swipe.thirdTrigger = 0.65
    
    // create the swipe buttons
    swipe.create(position: SwipeCell.Position.Left1, animation: .Slide, icon: UIImageView(image:UIImage(named: "check")), color: .greenColor()) { [unowned self] (cell) in

    }
    
    swipe.create(position: SwipeCell.Position.Left2, animation: .Slide, icon: UIImageView(image:UIImage(named: "list")), color: .brownColor()) { [unowned self] (cell) in

    }
    
    swipe.create(position: SwipeCell.Position.Left3, animation: .Slide, icon: UIImageView(image:UIImage(named: "clock")), color: .purpleColor()) { [unowned self] (cell) in

    }
    
    swipe.create(position: SwipeCell.Position.Right1, animation: .Bounce, icon: UIImageView(image:UIImage(named: "cross")), color: .redColor()) { [unowned self] (cell) in

    }
  }
```  

```swift
  // MARK: - optional swipe delegates
  func tableViewCellDidStartSwiping(cell cell: UITableViewCell) {
  }
  
  func tableViewCellDidEndSwiping(cell cell: UITableViewCell) {
  }
  
  func tableViewCell(cell cell: UITableViewCell, didSwipeWithPercentage percentage: CGFloat) {
  }
```

**status** working.

![gif](http://i.imgur.com/Xxs98f1.gif)
