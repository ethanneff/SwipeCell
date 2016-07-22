//
//  TableViewController.swift
//  swipe
//
//  Created by Ethan Neff on 3/11/16.
//  Copyright © 2016 Ethan Neff. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  // MARK: - properties
  private var tableView: UITableView?
  private var items: [Int]
  private var header: String!
  
  // MARK: - init
  init() {
    tableView = UITableView()
    items = [1,2,3,4,5]
    super.init(nibName: nil, bundle: nil)
    setupTableView()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - layout
extension ViewController {
  private func setupTableView() {
    guard let tableView = tableView else { return }
    
    // add
    view.addSubview(tableView)
    
    // handlers
    tableView.delegate = self
    tableView.dataSource = self
    
    // full length separator
    tableView.contentInset = UIEdgeInsetsZero
    tableView.separatorInset = UIEdgeInsetsZero
    tableView.scrollIndicatorInsets = UIEdgeInsetsZero
    tableView.layoutMargins = UIEdgeInsetsZero
    if #available(iOS 9.0, *) {
      tableView.cellLayoutMarginsFollowReadableWidth = false
    }
    
    // white background
    tableView.tableFooterView = UIView(frame: CGRect.zero)
    
    // cell
    tableView.registerClass(TableViewCell.self, forCellReuseIdentifier: TableViewCell.identifier)
    
    // constraints
    tableView.translatesAutoresizingMaskIntoConstraints = false
    var constraints = [NSLayoutConstraint]()
    constraints.append(NSLayoutConstraint(item: tableView, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1, constant: 0))
    constraints.append(NSLayoutConstraint(item: tableView, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: 0))
    constraints.append(NSLayoutConstraint(item: tableView, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .Leading, multiplier: 1, constant: 0))
    constraints.append(NSLayoutConstraint(item: tableView, attribute: .Trailing, relatedBy: .Equal, toItem: view, attribute: .Trailing, multiplier: 1, constant: 0))
    NSLayoutConstraint.activateConstraints(constraints)
  }
}

// MARK: - table view handling
extension ViewController: UITableViewDelegate, UITableViewDataSource {
  // MARK: - cell
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return items.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    // custom tableview cell
    let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCell.identifier, forIndexPath: indexPath) as! TableViewCell
    // pass the cell data
    cell.load(data: items[indexPath.row])
    // listen for any swipe button completions (SwipeCompleteDelegate)
    cell.swipeDelegate = self
    return cell
  }
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return TableViewCell.height
  }
  
  func deleteCell(cell cell: UITableViewCell) {
    guard let indexPath = tableView?.indexPathForCell(cell) else { return }
    items.removeAtIndex(indexPath.row)
    tableView?.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
  }
  
  func insertCell(cell cell: UITableViewCell) {
    guard let indexPath = tableView?.indexPathForCell(cell) else { return }
    let newIndexPath = NSIndexPath(forRow: indexPath.row+1, inSection: indexPath.section)
    items.insert(items[indexPath.row]*10, atIndex: newIndexPath.row)
    tableView?.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
  }
}

// MARK: - swipe complete delegate
extension ViewController: SwipeCompleteDelegate {
  func swipeComplete(cell cell: UITableViewCell, position: SwipeCell.Position) {
    if position == .Left1 {
      insertCell(cell: cell)
    }
    if position == .Right1 {
      deleteCell(cell: cell)
    }
  }
}
