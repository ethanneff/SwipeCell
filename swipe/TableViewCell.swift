//
//  TableViewCell.swift
//  swipe
//
//  Created by Ethan Neff on 7/22/16.
//  Copyright © 2016 Ethan Neff. All rights reserved.
//

import UIKit

// how the cell communicates to the parent view controller
protocol SwipeCompleteDelegate: class {
  func swipeComplete(cell cell: UITableViewCell, position: SwipeCell.Position)
}

class TableViewCell: UITableViewCell {
  // MARK: - properties
  static let identifier: String = "cell"
  static let height: CGFloat = 40
  
  private var swipe: SwipeCell!
  weak var swipeDelegate: SwipeCompleteDelegate?
  
  // MARK: - init
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setupDefaults()
    setupSwipe()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - layout
extension TableViewCell {
  internal func load(data data: Int) {
    textLabel?.text = String(data)
  }
  
  private func setupDefaults() {
    separatorInset = UIEdgeInsetsZero
    layoutMargins = UIEdgeInsetsZero
    selectionStyle = .None
  }
}

// MARK: - swipe setup
extension TableViewCell {
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
    // TODO: make [unowned self] default implimentation to prevent closure strong reference cycle
    swipe.create(position: SwipeCell.Position.Left1, animation: .Slide, icon: UIImageView(image:UIImage(named: "check")), color: .greenColor()) { [unowned self] (cell) in
      // send the completed choice from the cell to the view controller
      self.swipeDelegate?.swipeComplete(cell: cell, position: .Left1)
    }
    
    swipe.create(position: SwipeCell.Position.Left2, animation: .Slide, icon: UIImageView(image:UIImage(named: "list")), color: .brownColor()) { [unowned self] (cell) in
      self.swipeDelegate?.swipeComplete(cell: cell, position: .Left2)
    }
    
    swipe.create(position: SwipeCell.Position.Left3, animation: .Slide, icon: UIImageView(image:UIImage(named: "clock")), color: .purpleColor()) { [unowned self] (cell) in
      self.swipeDelegate?.swipeComplete(cell: cell, position: .Left3)
    }
    
    swipe.create(position: SwipeCell.Position.Right1, animation: .Bounce, icon: UIImageView(image:UIImage(named: "cross")), color: .redColor()) { [unowned self] (cell) in
      self.swipeDelegate?.swipeComplete(cell: cell, position: .Right1)
    }
  }
}

// MARK: - optional swipe delegate
extension TableViewCell: SwipeCellDelegate {
  func tableViewCellDidStartSwiping(cell cell: UITableViewCell) {
//    print("started swiping")
  }
  
  func tableViewCellDidEndSwiping(cell cell: UITableViewCell) {
//    print("ended swiping")
  }
  
  func tableViewCell(cell cell: UITableViewCell, didSwipeWithPercentage percentage: CGFloat) {
    //    print("swiping percent: \(percentage)")
  }
}