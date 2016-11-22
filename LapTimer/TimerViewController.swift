//
//  ViewController.swift
//  LapTimer
//
//  Created by John Keith on 9/24/16.
//  Copyright © 2016 John Keith. All rights reserved.
//

import UIKit
import AVFoundation

class TimerViewController: UIViewController, AVSpeechSynthesizerDelegate {
    let synth = AVSpeechSynthesizer()
    
    var timerCounter = "00:00:00"
    var lapCounter = "00:00:00"
    var timer = Timer()
    var startTime = NSDate.timeIntervalSinceReferenceDate
    var startLapTime = NSDate.timeIntervalSinceReferenceDate
    var lapTimes = [(text: String, time: Double)]()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        synth.delegate = self
        setAudioDefaults()
        
        timerCounterDisplay.text = timerCounter
        lapTimerDisplay.text = lapCounter
        
        self.view.backgroundColor = Constants.colorPalette["gray"]
        
        setBordersForView(targetView: lapRestartView)
        setBordersForView(targetView: pauseResetView)
        setBordersForView(targetView: lapButton)
        setBordersForView(targetView: restartButton)
        setBordersForView(targetView: resetButton)
        setBordersForView(targetView: pauseButton)
        setButtonColors()
        setDropShadowForView(targetView: lapRestartView)
        setDropShadowForView(targetView: pauseResetView)
        
        let lapButtonFont = UIFont.monospacedDigitSystemFont(ofSize: 48, weight: UIFontWeightLight)
        lapTimerDisplay.font = lapButtonFont
        timerCounterDisplay.font = lapButtonFont
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setDropShadowForView(targetView: UIView) {
        let shadowPath = UIBezierPath(rect: targetView.bounds)
//        targetView.layer.masksToBounds = false
        targetView.layer.shadowColor = Constants.colorPalette["light-orange"]?.cgColor
        targetView.layer.shadowOffset = CGSize(width: 0, height: 5)
        targetView.layer.shadowOpacity = 0.4
//        targetView.layer.shadowPath = shadowPath.cgPath
        targetView.layer.shadowRadius = 5.0
    }
    
    func setBordersForView(targetView: AnyObject, borderWidth: CGFloat = CGFloat(2.0), borderRadius: CGFloat = CGFloat(4.0), borderColor: CGColor = UIColor.white.cgColor) {
        targetView.layer.borderWidth = borderWidth
        targetView.layer.cornerRadius = borderRadius
        targetView.layer.borderColor = borderColor
    }
    
    func setButtonColors() {
        lapButton.backgroundColor = Constants.colorPalette["dark-blue"]
        restartButton.backgroundColor = Constants.colorPalette["dark-gray"]
        resetButton.backgroundColor = Constants.colorPalette["dark-orange"]
        pauseButton.backgroundColor = Constants.colorPalette["light-orange"]
    }

    @IBOutlet weak var lapTimerLabel: UILabel!
    @IBOutlet weak var timerCounterDisplay: UILabel!
    @IBOutlet weak var lapTimerDisplay: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var lapButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var restartButton: UIButton!
    @IBOutlet weak var totalTimeLabel: UILabel!
    @IBOutlet weak var totalTimeView: UIView!
    @IBOutlet weak var lapTimeView: UIView!
    @IBOutlet weak var pauseResetView: UIView!
    @IBOutlet weak var lapRestartView: UIView!
   
    @IBAction func unwindToTimer (sender: UIStoryboardSegue){}

    @IBAction func startTimer(_ sender: AnyObject) {
        self.view.backgroundColor = Constants.colorPalette["blue-background"]
        
        springAnimationForView(targetView: lapRestartView)
        springAnimationForView(targetView: pauseResetView)
        
        timer.invalidate()
        
        startTime = NSDate.timeIntervalSinceReferenceDate
        startLapTime = NSDate.timeIntervalSinceReferenceDate
        
        initTimer()
        
        startButton.isHidden = true
        
        totalTimeView.isHidden = false
        lapTimeView.isHidden = false
        lapRestartView.isHidden = false
        pauseResetView.isHidden = false
        
        lapButton.isHidden = false
        pauseButton.isHidden = false
        print("start hit")
    }
    
//    func clearStartButtonTitle() {
//        startButton.setTitle("", for: .normal)
//    }
//    
//    func animateStartButtonTransition() {
//        UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions.allowUserInteraction, animations: { () -> Void in
//            self.startButton.backgroundColor = UIColor.white;
//        })
//    }
    
    @IBAction func pauseTimer(_ sender: AnyObject) {
        self.view.backgroundColor = Constants.colorPalette["gray"]
        timer.invalidate()
        
        restartButton.isHidden = false
        resetButton.isHidden = false
        lapButton.isHidden = true
        pauseButton.isHidden = true

        print("pause hit")
    }
    
    @IBAction func resetTimer(_ sender: AnyObject) {
        timerCounterDisplay.text = "00:00:00"
        lapTimerDisplay.text = "00:00:00"
        
        lapTimes.removeAll()
        lapTimerLabel.text = "Lap Time"
        
        restartButton.isHidden = true
        resetButton.isHidden = true
        startButton.isHidden = false
        
        totalTimeView.isHidden = true
        lapTimeView.isHidden = true
        lapRestartView.isHidden = true
        pauseResetView.isHidden = true
        
        print("reset hit")
    }
    
    @IBAction func restartTimer(_ sender: AnyObject) {
        self.view.backgroundColor = Constants.colorPalette["blue-background"]
        
        initTimer()
        
        restartButton.isHidden = true
        resetButton.isHidden = true
        pauseButton.isHidden = false
        lapButton.isHidden = false

        print("restart hit")
    }
    
    var disableLapButton = false
    
    @IBAction func storeLap(_ sender: AnyObject) {
        if disableLapButton == false {
            disableLapButton = true
            let results = timerUpdate(initialTime: startLapTime)
            let sentancePrefix = "\(lapTimes.count + 1)\(ordinalSuffixForNumber(number: lapTimes.count + 1)) lap time was"
            var lapTimeToSpeak = convertLapTimeToText(timeString: results.text, sentancePrefix: sentancePrefix)
            
            lapTimes.insert(results, at: 0)

            if lapTimes.count > 1 {
                let averageLapTime = calculateAverageLapTime(_lapTimes: lapTimes)
                let averageLapTimeAsString = timeElapsedAsString(inputTime: averageLapTime)
                let averageLapTimeToSpeak = convertLapTimeToText(timeString: averageLapTimeAsString, sentancePrefix: "Your average lap time is")
                lapTimeToSpeak += averageLapTimeToSpeak
            }
            
            textToSpeech(text: lapTimeToSpeak)
            
            startLapTime = NSDate.timeIntervalSinceReferenceDate
            
            print("lap hit")
            lapTimerLabel.text = "Lap \(lapTimes.count + 1) Time"
            print("lap hit")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                self.disableLapButton = false
            }
        }
    }
    
    func convertLapTimeToText(timeString: String, sentancePrefix: String) -> String {
        let splitTimeString = timeString.components(separatedBy: ":")
        let minutes = splitTimeString[0]
        let seconds = splitTimeString[1]
        let minutesInt = Int(minutes)
        let secondsInt = Int(seconds)
        
        var convertedString = sentancePrefix
        
        if minutesInt! > 0 {
            convertedString += " \(minutes) minute"
        }
        
        if minutesInt! > 1 {
            convertedString += "s"
        }
        
        if minutesInt! > 0 && secondsInt! > 0 {
            convertedString += " and"
        }
        
        if secondsInt! > 0 {
            convertedString += " \(seconds) second"
        }
        
        if secondsInt! > 1 {
            convertedString += "s"
        }
        
        return convertedString
    }
    
    func textToSpeech(text: String) {
        let myUtterance = AVSpeechUtterance(string: text)
        myUtterance.rate = 0.5

        activateAudioAndSpeak(utterance: myUtterance)
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        deactivateAudio()
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
        let results = timerUpdate(initialTime: startTime)

        timerCounterDisplay.text = results.text
        
        updateLapTimer()
    }
    
    func updateLapTimer() {
        let results = timerUpdate(initialTime: startLapTime)
        
        lapTimerDisplay.text = results.text
    }
    
    func timerUpdate(initialTime: Double) -> (text: String, time: Double) {
        let currentTime = NSDate.timeIntervalSinceReferenceDate
        let elapsedTime: TimeInterval = currentTime - initialTime
        let text = timeElapsedAsString(inputTime: elapsedTime)
        
        return (text: text, time: elapsedTime)
    }
    
    func timeElapsedAsString(inputTime: Double) -> String {
        let (strMinutes, strSeconds, strFraction) = timeElapsedAsStrings(inputTime: inputTime)
        return timeDisplayString(times: [strMinutes, strSeconds, strFraction])
    }
    
    func timeElapsedAsStrings(inputTime: Double) -> (minutes: String, seconds: String, fraction: String) {
        var elapsedTime = inputTime
        
        let minutes = UInt8(elapsedTime / 60.0)
        
        elapsedTime -= (TimeInterval(minutes) * 60)
        
        let seconds = UInt8(elapsedTime)
        
        elapsedTime -= TimeInterval(seconds)
        
        let fraction = UInt8(elapsedTime * 100)
        
        let strMinutes = String(format: "%02d", minutes)
        let strSeconds = String(format: "%02d", seconds)
        let strFraction = String(format: "%02d", fraction)
        
        return (minutes: strMinutes, seconds: strSeconds, fraction: strFraction)
    }
    
    func timeDisplayString(times: [String]) -> String {
        return times.joined(separator: ":")
    }
    
    func calculateAverageLapTime(_lapTimes: [(text: String, time: Double)]) -> Double {
        let totalLapTime = _lapTimes.map{$0.time}.reduce(0, +)
        return totalLapTime / Double(_lapTimes.count)
    }

    
    func ordinalSuffixForNumber(number: Int) -> String {
        switch (number) {
        case 1:
            return "st"
        case 2:
            return "nd"
        case 3:
            return "rd"
        default:
            return "th"
        }
    }
    
    func setAudioDefaults() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: [AVAudioSessionCategoryOptions.duckOthers, AVAudioSessionCategoryOptions.interruptSpokenAudioAndMixWithOthers])
        } catch {
            print("there was an error setting audio defaults")
        }
    }
    
    func activateAudioAndSpeak(utterance: AVSpeechUtterance) {
        DispatchQueue.global(qos: .background).async {
            do {
                try AVAudioSession.sharedInstance().setActive(true)
                print("set audio active")
                self.synth.speak(utterance)
            } catch {
                print("there was an error activating audio")
            }
        }
    }
    
    func deactivateAudio() {
        DispatchQueue.global(qos: .background).async {
            do {
              try AVAudioSession.sharedInstance().setActive(false)
                print("set audit session inactive")
            } catch {
                print("there was an error deactivating audio")
            }
        }
    }
    
    func springAnimationForView(targetView: UIView) {
        targetView.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        
        UIView.animate(withDuration: 0.5,
           delay: 0,
           usingSpringWithDamping: 1,
           initialSpringVelocity: 6.0,
           options: .allowUserInteraction,
           animations: {
            targetView.transform = .identity
        },
           completion: nil)
    }
    
    func buttonPressAnimation(targetButton: UIButton) {
        UIView.animate(withDuration: 1.0,
            animations: {
            }
        )
    }

}

