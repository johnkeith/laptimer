//
//  SettingsViewController.swift
//  LapTimer
//
//  Created by John Keith on 11/14/16.
//  Copyright © 2016 John Keith. All rights reserved.
//

import Foundation
import UIKit

class SettingsViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = Constants.colorPalette["gray"]
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBOutlet weak var lapsPerMileInput: UITextField!
    @IBOutlet weak var lapsPerMileView: UIView!    
    
    // next is core data and saving prefs to persist across sessions
    // also want to consider redesign - strip labels, show in 1/4, 3/4 sections 
}
