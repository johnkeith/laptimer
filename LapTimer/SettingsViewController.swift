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
    let globalPrefs = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = Constants.colorPalette["gray"]
        lapsPerMileInput.text = "\(globalPrefs.integer(forKey: "lapsPerMile"))"
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBOutlet weak var lapsPerMileInput: UITextField!
    @IBOutlet weak var lapsPerMileView: UIView!
    
    
    @IBAction func lapsPerMileEditingFinished(_ sender: AnyObject) {
        let lapsPerMileInt = Int(lapsPerMileInput.text!)
        globalPrefs.set(lapsPerMileInt!, forKey: "lapsPerMile")
    }
}
