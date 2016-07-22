//
//  SwipeTableViewCell.swift
//  swipe
//
//  Created by Ethan Neff on 3/11/16.
//  Copyright © 2016 Ethan Neff. All rights reserved.
//
import UIKit

// delegate
protocol SwipeCellDelegate: class {
  func tableViewCellDidStartSwiping(cell cell: UITableViewCell)
  func tableViewCellDidEndSwiping(cell cell: UITableViewCell)
  func tableViewCell(cell cell: UITableViewCell, didSwipeWithPercentage percentage: CGFloat)
}

// make optional functions
extension SwipeCellDelegate {
  func tableViewCellDidStartSwiping(cell cell: UITableViewCell) {}
  func tableViewCellDidEndSwiping(cell cell: UITableViewCell) {}
  func tableViewCell(cell cell: UITableViewCell, didSwipeWithPercentage percentage: CGFloat) {}
}

// cell swipe feature
// view controller to encapsulate for gestures
class SwipeCell: UIViewController, UIGestureRecognizerDelegate {
  // MARK: - PROPERTIES
  
  // required
  weak var cell: UITableViewCell!
  
  // optional
  weak var delegate: SwipeCellDelegate?
  
  // constants
  let kDurationLowLimit: NSTimeInterval = 0.25
  let kDurationHighLimit: NSTimeInterval = 0.10
  let kVelocity: CGFloat = 0.70
  let kDamping: CGFloat = 0.50
  let kAnimationSlideDelay: Double = 0.30
  
  // public
  var shouldDrag: Bool = true
  var shouldAnimateIcons: Bool = true
  var firstTrigger: CGFloat = 0.15
  var secondTrigger: CGFloat = 0.35
  var thirdTrigger: CGFloat = 0.55
  var forthTrigger: CGFloat = 0.75
  var defaultColor: UIColor = .lightGrayColor()
  
  // private
  private var gesture: UIPanGestureRecognizer!
  private var dragging: Bool = false
  private var isExiting: Bool = false
  private lazy var contentScreenshotView: UIImageView = UIImageView()
  private lazy var colorIndicatorView: UIView = UIView()
  private lazy var iconView: UIView = UIView()
  private var direction: Direction = .Center
  
  private var Left1: Container?
  private var Left2: Container?
  private var Left3: Container?
  private var Left4: Container?
  private var Right1: Container?
  private var Right2: Container?
  private var Right3: Container?
  private var Right4: Container?
  
  typealias Completion = (cell: UITableViewCell) -> ()
  
  enum Position {
    case Left1
    case Left2
    case Left3
    case Left4
    case Right1
    case Right2
    case Right3
    case Right4
  }
  
  enum Animation {
    case Bounce
    case Slide
  }
  
  private enum Direction {
    case Center
    case Left
    case Right
  }
  
  private struct Container {
    // the swipe gesture object per cell
    var color: UIColor
    var icon: UIView
    var animation: Animation
    var completion: Completion
    
    init(color: UIColor, animation: Animation, icon: UIView, completion: Completion) {
      self.color = color
      self.animation = animation
      self.icon = icon
      self.completion = completion
    }
  }
  
  
  
  // MARK: - INIT
  init(cell: UITableViewCell) {
    self.cell = cell
    super.init(nibName: nil, bundle: nil)
    initialize()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init coder not implemented")
  }
  
  private func initialize() {
    gesture = UIPanGestureRecognizer(target: self, action: #selector(handleSwipeGesture(_:)))
    gesture.maximumNumberOfTouches = 1
    gesture.delegate = self
    cell.addGestureRecognizer(gesture)
  }
  
  
  // MARK: - DEINIT
  deinit {
    dealloc()
  }
  
  private func dealloc() {
    iconView.removeFromSuperview()
    colorIndicatorView.removeFromSuperview()
    contentScreenshotView.removeFromSuperview()
    
    delegate = nil
    gesture = nil
    isExiting = false
  }
  
  
  // MARK: - PUBLIC ADD SWIPE
  internal func create(position position: Position, animation: Animation, icon: UIImageView, color: UIColor, completion: Completion) {
    // public function to add a new gesture on the cell
    switch position {
    case .Left1: Left1 = Container(color: color, animation: animation, icon: icon, completion: completion)
    case .Left2: Left2 = Container(color: color, animation: animation, icon: icon, completion: completion)
    case .Left3: Left3 = Container(color: color, animation: animation, icon: icon, completion: completion)
    case .Left4: Left4 = Container(color: color, animation: animation, icon: icon, completion: completion)
    case .Right1: Right1 = Container(color: color, animation: animation, icon: icon, completion: completion)
    case .Right2: Right2 = Container(color: color, animation: animation, icon: icon, completion: completion)
    case .Right3: Right3 = Container(color: color, animation: animation, icon: icon, completion: completion)
    case .Right4: Right4 = Container(color: color, animation: animation, icon: icon, completion: completion)
    }
  }
  
  
  
  // MARK: - GESTURE RECOGNIZER
  internal func handleSwipeGesture(gesture: UIPanGestureRecognizer) {
    if !shouldDrag || isExiting {
      return
    }
    
    let state = gesture.state
    let translation = gesture.translationInView(cell)
    let velocity = gesture.velocityInView(cell)
    let percentage = getPercentage(offset: CGRectGetMinX(contentScreenshotView.frame), width: CGRectGetWidth(cell.bounds))
    let duration = getAnimationDuration(velocity: velocity)
    let direction = getDirection(percentage: percentage)
    
    if state == .Began {
      // began
      dragging = true
      let snapshot = createScreenShot(cell)
      createView(snapshot: snapshot)
      delegate?.tableViewCellDidStartSwiping(cell: cell)
    } else if state == .Changed {
      // changed (moving)
      gesture.setTranslation(CGPointZero, inView: cell)
      contentScreenshotView.center = CGPoint(x: contentScreenshotView.center.x + translation.x, y: contentScreenshotView.center.y)
      moveCell(offset: CGRectGetMinX(contentScreenshotView.frame), direction: direction)
      delegate?.tableViewCell(cell: cell, didSwipeWithPercentage: percentage)
    } else if state == .Cancelled || state == .Ended {
      // ended or cancelled
      dragging = false
      isExiting = true
      completeCell(percentage: percentage, duration: duration, direction: direction)
      delegate?.tableViewCellDidEndSwiping(cell: cell)
    }
  }
  
  internal func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
    // needed to allow scrolling of the tableview
    if let g = gestureRecognizer as? UIPanGestureRecognizer {
      let point: CGPoint = g.velocityInView(cell)
      // if moving x instead of y
      if fabs(point.x) > fabs(point.y) {
        // prevent swipe if there is no gesture in that direction
        if !getGestureDirection(direction: .Left) && point.x < 0 {
          return false
        }
        if !getGestureDirection(direction: .Right) && point.x > 0 {
          return false
        }
        return true
      }
    }
    return false
  }
  
  
  
  // MARK: - BEGIN
  private func createScreenShot(view: UIView) -> UIImage {
    // create a snapshot (copy) of the cell
    let scale: CGFloat = UIScreen.mainScreen().scale
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, scale)
    view.layer.renderInContext(UIGraphicsGetCurrentContext()!)
    let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return image
  }
  
  private func createView(snapshot snapshot: UIImage) {
    // add snapshot image to cell
    colorIndicatorView = UIView(frame: cell.bounds)
    colorIndicatorView.autoresizingMask = ([.FlexibleHeight, .FlexibleWidth])
    colorIndicatorView.backgroundColor = defaultColor
    cell.addSubview(colorIndicatorView)
    
    iconView = UIView()
    iconView.contentMode = .Center
    colorIndicatorView.addSubview(iconView)
    
    // cell snapshot
    contentScreenshotView = UIImageView(image: snapshot)
    cell.addSubview(contentScreenshotView)
  }
  
  
  
  // MARK: - CHANGED
  private func moveCell(offset offset: CGFloat, direction: Direction) {
    // move the cell when swipping
    let percentage = getPercentage(offset: offset, width: CGRectGetWidth(cell.bounds))
    if let object = getSwipeObject(percentage: percentage) {
      // change to the correct icons and colors
      colorIndicatorView.backgroundColor = getBeforeTrigger(percentage: percentage, direction: direction) ? defaultColor : object.color
      resetIcon(icon: object.icon)
      updateIcon(percentage: percentage, direction: direction, icon: object.icon, isDragging: shouldAnimateIcons)
    } else {
      colorIndicatorView.backgroundColor = defaultColor
    }
  }
  
  private func resetIcon(icon icon: UIView) {
    // remove the old icons when changing between sections
    let subviews = iconView.subviews
    for view in subviews {
      view.removeFromSuperview()
    }
    // add the new icon
    iconView.addSubview(icon)
  }
  
  private func updateIcon(percentage percentage: CGFloat, direction: Direction, icon: UIView, isDragging: Bool) {
    // position the icon when swiping
    var position: CGPoint = CGPointZero
    position.y = CGRectGetHeight(cell.bounds) / 2
    if isDragging {
      // near the cell
      if percentage >= 0 && percentage < firstTrigger {
        position.x = getOffset(percentage: (firstTrigger / 2), width: CGRectGetWidth(cell.bounds))
      } else if percentage >= firstTrigger {
        position.x = getOffset(percentage: percentage - (firstTrigger / 2), width: CGRectGetWidth(cell.bounds))
      } else if percentage < 0 && percentage >= -firstTrigger {
        position.x = CGRectGetWidth(cell.bounds) - getOffset(percentage: (firstTrigger / 2), width: CGRectGetWidth(cell.bounds))
      } else if percentage < -firstTrigger {
        position.x = CGRectGetWidth(cell.bounds) + getOffset(percentage: percentage + (firstTrigger / 2), width: CGRectGetWidth(cell.bounds))
      }
    } else {
      // float either left or right
      if direction == .Right {
        position.x = getOffset(percentage: (firstTrigger / 2), width: CGRectGetWidth(cell.bounds))
      } else if direction == .Left {
        position.x = CGRectGetWidth(cell.bounds) - getOffset(percentage: (firstTrigger / 2), width: CGRectGetWidth(cell.bounds))
      } else {
        return
      }
    }
    let activeViewSize: CGSize = icon.bounds.size
    var activeViewFrame: CGRect = CGRectMake(position.x - activeViewSize.width / 2, position.y - activeViewSize.height / 2, activeViewSize.width, activeViewSize.height)
    activeViewFrame = CGRectIntegral(activeViewFrame)
    iconView.frame = activeViewFrame
    iconView.alpha = getAlpha(percentage: percentage)
  }
  
  
  
  // MARK: - END
  private func completeCell(percentage percentage: CGFloat, duration: Double, direction: Direction) {
    // determine which completion animation
    if let object = getSwipeObject(percentage: percentage) {
      let icon = object.icon
      let completion = object.completion
      let animation = object.animation
      
      if getBeforeTrigger(percentage: percentage, direction: direction) || animation == .Bounce {
        // bounce
        directionBounce(duration: duration, direction: direction, icon: icon, percentage: percentage, completion: completion)
      } else {
        // slide
        directionSlide(duration: duration, direction: direction, icon: icon, completion: completion)
      }
    } else {
      // bounce
      directionBounce(duration: duration, direction: direction, icon: nil, percentage: percentage, completion: nil)
    }
  }
  
  private func directionBounce(duration duration: NSTimeInterval, direction: Direction, icon: UIView?, percentage: CGFloat, completion: Completion?) {
    let icon = icon ?? UIView()
    
    UIView.animateWithDuration(duration, delay: 0, usingSpringWithDamping: kDamping, initialSpringVelocity: kVelocity, options: .CurveEaseInOut, animations: { () -> Void in
      var frame: CGRect = self.contentScreenshotView.frame
      frame.origin.x = 0
      self.contentScreenshotView.frame = frame
      // clearing the indicator view
      self.colorIndicatorView.backgroundColor = self.defaultColor
      self.iconView.alpha = 0
      self.updateIcon(percentage: 0, direction: direction, icon: icon, isDragging: self.shouldAnimateIcons)
    }) { (finished) -> Void in
      // don't complete if before get trigger
      if let completion = completion where !self.getBeforeTrigger(percentage: percentage, direction: direction) {
        completion(cell: self.cell)
      }
      self.dealloc()
    }
  }
  
  private func directionSlide(duration duration: NSTimeInterval, direction: Direction, icon: UIView, completion: Completion) {
    // determine ending percentage
    var origin: CGFloat
    if direction == .Left {
      origin = -CGRectGetWidth(cell.bounds)
    } else if direction == .Right {
      origin = CGRectGetWidth(cell.bounds)
    } else {
      origin = 0
    }
    let percentage: CGFloat = getPercentage(offset: origin, width: CGRectGetWidth(cell.bounds))
    var frame: CGRect = contentScreenshotView.frame
    frame.origin.x = origin
    
    UIView.animateWithDuration(duration, delay: 0, options: ([.CurveEaseOut, .AllowUserInteraction]), animations: {() -> Void in
      self.contentScreenshotView.frame = frame
      self.iconView.alpha = 0
      self.updateIcon(percentage: percentage, direction: direction, icon: icon, isDragging: self.shouldAnimateIcons)
      }, completion: {(finished: Bool) -> Void in
        completion(cell: self.cell)
        // delay for animated swipe of cell
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(self.kAnimationSlideDelay * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
          self.dealloc()
        }
    })
  }
  
  
  
  // MARK: - GET
  private func getSwipeObject(percentage percentage: CGFloat) -> Container? {
    // determine if swipe object exits
    var object: Container?
    if let left1 = Left1 where percentage >= 0 {
      object = left1
    }
    if let left2 = Left2 where percentage >= secondTrigger {
      object = left2
    }
    if let left3 = Left3 where percentage >= thirdTrigger {
      object = left3
    }
    if let left4 = Left4 where percentage >= forthTrigger {
      object = left4
    }
    
    if let right1 = Right1 where percentage <= 0 {
      object = right1
    }
    if let right2 = Right2 where percentage <= -secondTrigger {
      object = right2
    }
    if let right3 = Right3 where percentage <= -thirdTrigger {
      object = right3
    }
    if let right4 = Right4 where percentage <= -forthTrigger {
      object = right4
    }
    
    return object
  }
  
  private func getBeforeTrigger(percentage percentage: CGFloat, direction: Direction) -> Bool {
    // if before the first trigger, do not run completion and bounce back
    if (direction == .Left && percentage > -firstTrigger) || (direction == .Right && percentage < firstTrigger) {
      return true
    }
    
    return false
  }
  
  
  private func getPercentage(offset offset: CGFloat, width: CGFloat) -> CGFloat {
    // get the percentage of the user drag
    var percentage = offset / width
    if percentage < -1 {
      percentage = -1
    } else if percentage > 1 {
      percentage = 1
    }
    
    return percentage
  }
  
  private func getOffset(percentage percentage: CGFloat, width: CGFloat) -> CGFloat {
    // get the offset of the user drag
    var offset: CGFloat = percentage * width
    if offset < -width {
      offset = -width
    } else if offset > width {
      offset = width
    }
    
    return offset
  }
  
  private func getAnimationDuration(velocity velocity: CGPoint) -> NSTimeInterval {
    // get the duration for the completing swipe
    let width: CGFloat = CGRectGetWidth(cell.bounds)
    let animationDurationDiff: NSTimeInterval = kDurationHighLimit - kDurationLowLimit
    var horizontalVelocity: CGFloat = velocity.x
    
    if horizontalVelocity < -width {
      horizontalVelocity = -width
    } else if horizontalVelocity > width {
      horizontalVelocity = width
    }
    
    let diff = abs(((horizontalVelocity / width) * CGFloat(animationDurationDiff)))
    
    return (kDurationHighLimit + kDurationLowLimit) - NSTimeInterval(diff)
  }
  
  func getAlpha(percentage percentage: CGFloat) -> CGFloat {
    // set the alpha of the icon before the first trigger
    var alpha: CGFloat
    if percentage >= 0 && percentage < firstTrigger {
      alpha = percentage / firstTrigger
    } else if percentage < 0 && percentage > -firstTrigger {
      alpha = fabs(percentage / firstTrigger)
    } else {
      alpha = 1
    }
    
    return alpha
  }
  
  private func getDirection(percentage percentage: CGFloat) -> Direction {
    // get the direction either left or right
    if percentage < 0 {
      return .Left
    } else if percentage > 0 {
      return .Right
    } else {
      return .Center
    }
  }
  
  private func getGestureDirection(direction direction: Direction) -> Bool {
    // used to prevent swiping if there is not gesture in a direction
    switch direction {
    case .Left:
      if let _ = Left1 {
        return true
      }
      if let _ = Left2 {
        return true
      }
      if let _ = Left3 {
        return true
      }
      if let _ = Left4 {
        return true
      }
      break
    case .Right:
      if let _ = Right1 {
        return true
      }
      if let _ = Right2 {
        return true
      }
      if let _ = Right3 {
        return true
      }
      if let _ = Right4 {
        return true
      }
      break
    case .Center: return false
    }
    
    return false
  }
}