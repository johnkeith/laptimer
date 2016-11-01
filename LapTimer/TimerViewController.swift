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
    let screenSize: CGRect = UIScreen.main.bounds
    
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
            // VIEW CUSTOMIZATION
//            let startButtonWidth = startButton.frame.size.width
//            startButton.layer.cornerRadius = startButtonWidth / 2.0
//            startButton.layer.borderWidth = 3.0
//            startButton.layer.borderColor = UIColor.white.cgColor
        
            let lapButtonFont = UIFont.monospacedDigitSystemFont(ofSize: 48, weight: UIFontWeightLight)
            lapTimerDisplay.font = lapButtonFont
            timerCounterDisplay.font = lapButtonFont
    }

    @IBOutlet weak var timerCounterDisplay: UILabel!
    @IBOutlet weak var lapTimerDisplay: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var lapButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var restartButton: UIButton!
    @IBOutlet weak var totalTimeLabel: UILabel!
   
    @IBAction func startTimer(_ sender: AnyObject) {
        timer.invalidate()
        
        startTime = NSDate.timeIntervalSinceReferenceDate
        startLapTime = NSDate.timeIntervalSinceReferenceDate
        
        initTimer()
        
//        toggleStartButton()
        clearStartButtonTitle()
        animateStartButtonTransition()
        
        lapTimerDisplay.isHidden = false
//        timerCounterDisplay.isHidden = false
//        totalTimeLabel.isHidden = false
        
//        toggleLapButton()
        togglePauseButton()
        print("start hit")
    }
    
    func clearStartButtonTitle() {
        startButton.setTitle("", for: .normal)
    }
    
    func animateStartButtonTransition() {
        UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions.allowUserInteraction, animations: { () -> Void in
            self.startButton.backgroundColor = UIColor.white;
        })
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
        lapTimerDisplay.text = "00:00:00"
        
        lapTimes.removeAll()
        
        toggleRestartButton()
        toggleResetButton()
//        toggleStartButton()
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
    
//    func setAudioPlaybackToContinue() {
//        do {
//            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: AVAudioSessionCategoryOptions.duckOthers)
//        } catch {}
//    }
}

