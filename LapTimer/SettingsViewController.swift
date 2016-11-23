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
    let prefs = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = Constants.colorPalette["gray"]
        lapsPerMileInput.text = "\(prefs.integer(forKey: "lapsPerMile"))"
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBOutlet weak var lapsPerMileInput: UITextField!
    @IBOutlet weak var lapsPerMileView: UIView!
    
    
    @IBAction func lapsPerMileEditingFinished(_ sender: AnyObject) {
        let lapsPerMileInt = Int(lapsPerMileInput.text!)
        prefs.set(lapsPerMileInt!, forKey: "lapsPerMile")
    }
    // next is core data and saving prefs to persist across sessions
}
