//
//  AppDelegate.swift
//  swipe
//
//  Created by Ethan Neff on 3/11/16.
//  Copyright © 2016 Ethan Neff. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  
  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    navigateToFirstController()
    return true
  }
  
  private func navigateToFirstController() {
    window = UIWindow(frame: UIScreen.mainScreen().bounds)
    guard let window = window else {
      return
    }
    window.rootViewController = NavigationController()
    window.makeKeyAndVisible()
  }
}

