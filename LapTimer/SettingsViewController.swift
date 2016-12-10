//
//  SettingsViewController.swift
//  LapTimer
//
//  Created by John Keith on 11/14/16.
//  Copyright © 2016 John Keith. All rights reserved.
//

import Foundation
import UIKit

class SettingsViewController: UIViewController, UITextFieldDelegate {
    let globalPrefs = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = Constants.colorPalette["gray"]
        addDoneButtonOnKeyboard(input: self.lapsPerMileInput)
        
        let mileNotifications = globalPrefs.bool(forKey: "playMileNotifications")
        mileNotificationsToggle.setOn(mileNotifications, animated: false)
        
        let lapsPerMile = globalPrefs.integer(forKey: "lapsPerMile")
        if(lapsPerMile > 0) {
            lapsPerMileInput.text = "\(lapsPerMile)"
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    @IBOutlet weak var lapsPerMileInput: UITextField!
    @IBOutlet weak var lapsPerMileView: UIView!
    @IBOutlet weak var mileNotificationsToggle: UISwitch!
    
    @IBAction func lapsPerMileEditingFinished(_ sender: AnyObject) {
        saveLapsPerMile();
    }
    
    @IBAction func mileNotificationsToggled(_ sender: UISwitch) {
        saveMileNotifications()
    }
    
    func saveLapsPerMile() {
        let lapsPerMileInt:Int? = Int(lapsPerMileInput.text!)
        globalPrefs.set(lapsPerMileInt, forKey: "lapsPerMile")
        self.view.endEditing(true)
    }
    
    func saveMileNotifications() {
        globalPrefs.set(mileNotificationsToggle.isOn, forKey: "playMileNotifications")
    }
    
    func addDoneButtonOnKeyboard(input: UITextField) {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle = UIBarStyle.default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(SettingsViewController.saveLapsPerMile))
        
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        input.inputAccessoryView = doneToolbar
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
