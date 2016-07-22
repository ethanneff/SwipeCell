//
//  NavigationController.swift
//  swipe
//
//  Created by Ethan Neff on 7/22/16.
//  Copyright © 2016 Ethan Neff. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {
  // MARK: - init
  init() {
    super.init(nibName: nil, bundle: nil)
    loadViewController()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - load
  private func loadViewController() {
    pushViewController(ViewController(), animated: true)
  }
}
