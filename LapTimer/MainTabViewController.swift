//
//  MainTabViewController.swift
//  LapTimer
//
//  Created by John Keith on 10/16/16.
//  Copyright © 2016 John Keith. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    @IBInspectable let defaultIndex: Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedIndex = defaultIndex
    }
}
