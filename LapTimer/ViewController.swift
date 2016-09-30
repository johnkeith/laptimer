//
//  ViewController.swift
//  LapTimer
//
//  Created by John Keith on 9/24/16.
//  Copyright © 2016 John Keith. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var timerCounter = "00:00:00"
    var lapCounter = "00:00:00"
    var timer = Timer()
    var startTime = NSDate.timeIntervalSinceReferenceDate
    var startLapTime = NSDate.timeIntervalSinceReferenceDate
    var lapTimes = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timerCounterDisplay.text = timerCounter
        lapCounterDisplay.text = lapCounter
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBOutlet weak var timerCounterDisplay: UILabel!
    @IBOutlet weak var lapCounterDisplay: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var lapButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var restartButton: UIButton!
    
    @IBAction func startTimer(_ sender: AnyObject) {
        timer.invalidate()
        
        startTime = NSDate.timeIntervalSinceReferenceDate
        startLapTime = NSDate.timeIntervalSinceReferenceDate
        
        initTimer()
        
        toggleStartButton()
        toggleLapButton()
        togglePauseButton()
        print("start hit")
    }
    
    @IBAction func pauseTimer(_ sender: AnyObject) {
        timer.invalidate()
        
        toggleRestartButton()
        toggleLapButton()
        togglePauseButton()
        toggleResetButton()
        print("pause hit")
    }
    
    @IBAction func resetTimer(_ sender: AnyObject) {
        timerCounterDisplay.text = "00:00:00"
        lapCounterDisplay.text = "00:00:00"
        
        toggleRestartButton()
        toggleResetButton()
        toggleStartButton()
        print("reset hit")
    }
    
    @IBAction func restartTimer(_ sender: AnyObject) {
        initTimer()
        
        toggleRestartButton()
        toggleResetButton()
        togglePauseButton()
        toggleLapButton()
        print("restart hit")
    }
    
    @IBAction func storeLap(_ sender: AnyObject) {
        let finalLapTime = timerUpdate(initialTime: startLapTime)
        
        lapTimes.insert(finalLapTime, at: 0)

        startLapTime = NSDate.timeIntervalSinceReferenceDate
        
        print("lap hit")
    }
    
    func initTimer() {
        timer = Timer.scheduledTimer(
            timeInterval: 0.01,
            target: self,
            selector: #selector(updateMainTimer),
            userInfo: nil,
            repeats: true
        )
    }
    
    func updateMainTimer() {
        let timerCounterDisplayText = timerUpdate(initialTime: startTime)

        timerCounterDisplay.text = timerCounterDisplayText
        
        updateLapTimer()
    }
    
    func updateLapTimer() {
        let lapCounterDisplayText = timerUpdate(initialTime: startLapTime)
        
        lapCounterDisplay.text = lapCounterDisplayText
    }
    
    func timerUpdate(initialTime: Double) -> String {
        let currentTime = NSDate.timeIntervalSinceReferenceDate
        
        var elapsedTime: TimeInterval = currentTime - initialTime
        
        let minutes = UInt8(elapsedTime / 60.0)
        
        elapsedTime -= (TimeInterval(minutes) * 60)
        
        let seconds = UInt8(elapsedTime)
        
        elapsedTime -= TimeInterval(seconds)
        
        let fraction = UInt8(elapsedTime * 100)
        
        let strMinutes = String(format: "%02d", minutes)
        let strSeconds = String(format: "%02d", seconds)
        let strFraction = String(format: "%02d", fraction)
        
        return "\(strMinutes):\(strSeconds):\(strFraction)"
    }
    
    func toggleLapButton() {
        lapButton.isHidden = !lapButton.isHidden
    }
    
    func togglePauseButton() {
        pauseButton.isHidden = !pauseButton.isHidden
    }
    
    func toggleStartButton() {
        startButton.isHidden = !startButton.isHidden
    }
    
    func toggleResetButton() {
        resetButton.isHidden = !resetButton.isHidden
    }
    
    func toggleRestartButton() {
        restartButton.isHidden = !restartButton.isHidden
    }
}

