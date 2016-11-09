//
//  ViewController.swift
//  carpeDialarm
//
//  Created by Kevin Doherty on 5/30/16.
//  Copyright © 2016 Kevin Doherty. All rights reserved.
//

import UIKit
import AVFoundation
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, ESTBeaconManagerDelegate, AVAudioPlayerDelegate {

   
    @IBOutlet weak var alarmTimeButton: UIButton!
    
    @IBOutlet weak var alarmOnOffSwitch: UISwitch!
    
    @IBOutlet var alarmTimePickerView: AlarmTimePickerView!
    
    var dateAndTime = Date()
    
    var alarmPickedTimeDate = Date()
    
    var buttonStartTime = Date()
    
    var alarmSetTime = String()
    
    var alarmSetTimeShortDateStyle = String()
    
    var currentMenuView: UIView?
    
    var convertedDate = String()
    
    var alarmPickedTime = String()
    
    let locationManager = CLLocationManager()
    
    var alarmActivated = Bool()
    
    var systemSoundID = SystemSoundID()
    
    let beaconManager: ESTBeaconManager = ESTBeaconManager()
    
    var beaconRegion: CLBeaconRegion = CLBeaconRegion()
    
    var secondsTillAlarmFromArray = TimeInterval()
    
    var timeIntervalTillAlarmForDelegate = TimeInterval()
    
    var audioPlayer: AVAudioPlayer = AVAudioPlayer()
    
    let notification = UILocalNotification()
    
    var timer = Timer()
    
    var beacon = CLBeacon()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    
        let formatter = DateFormatter()
        formatter.locale =  Locale.current
        buttonStartTime = Date()
        alarmSetTime = DateFormatter.localizedString(from: buttonStartTime, dateStyle: .none, timeStyle: .short)
    
        alarmTimeButton.setTitle(alarmSetTime, for: UIControlState())
        alarmTimeButton.layer.cornerRadius = 10
    
        alarmTimePickerView.frame = CGRect(x: view.frame.origin.x, y: view.frame.height, width: view.frame.width, height: alarmTimePickerView.frame.height)
        alarmTimePickerView.delegate = self
        view.addSubview(alarmTimePickerView)
        print("the current time at view did load is NSDate \(dateAndTime)" )
    
    
        self.locationManager.delegate = self
        self.locationManager.requestAlwaysAuthorization()
//        self.locationManager.allowsBackgroundLocationUpdates = true
    
        self.audioPlayer = AVAudioPlayer()
    
        let session = AVAudioSession.sharedInstance()
    
        do {
            try session.setCategory(AVAudioSessionCategoryPlayback)
            try session.setActive(true)
            
        } catch let error as NSError {
            print("AVAudioSession configuration error: \(error.localizedDescription)")
        }
    
        var audioFileName = String()
        audioFileName = "railroad_crossing_bell-"
        var soundURL = NSObject()
        soundURL = Bundle.main.path(forResource: audioFileName, ofType: "mp3")! as NSObject
        var sound = URL(fileURLWithPath: soundURL as! String)

        do {
                self.audioPlayer = try AVAudioPlayer(contentsOf: sound)
                print("audioPlayer = try AVAudioPlayer(contentsOfURL: sound!)")
            
        }
        catch{
            
        }
            self.audioPlayer.prepareToPlay()
            self.audioPlayer.delegate = self
            print("AVAudioSession is set to railroad")
    
        beaconManager.delegate = self
        self.beaconManager.requestAlwaysAuthorization()
        beaconRegion = CLBeaconRegion(proximityUUID: UUID(uuidString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")!, identifier: "alarmBeacon region")
        beaconRegion.notifyOnEntry = true
        beaconRegion.notifyOnExit = false
    
        //self.locationManager.startUpdatingLocation()
    }
    
    func beaconManager(_ manager: AnyObject, didEnterRegion region: CLBeaconRegion) {
        self.audioPlayer.stop()
        print("entered the region" )
        self.alarmActivated = false

    }

    override func viewDidAppear(_ animated: Bool) {
        let famousAlert = UIAlertController(title: "Where's your sensor?", message: "Make sure your sensor is far away from your bed", preferredStyle: UIAlertControllerStyle.actionSheet)

        famousAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        
        present(famousAlert, animated: true, completion: nil)
    }

//func beaconManager(manager: AnyObject, didExitRegion region: CLBeaconRegion) {
//        print("exited the region")
//    }
//    
//
//func beaconManager(manager: AnyObject, monitoringDidFailForRegion region: CLBeaconRegion?, withError error: NSError) {
//        print("region did fail \(manager) \(region) \(error)")
//    }
//
//
//func beaconManager(manager: AnyObject, didStartMonitoringForRegion region: CLBeaconRegion) {
//        
//        print("did start monitoring region")
//    }


    func beaconManager(_ manager: AnyObject, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
        if beacons.count > 0{
            beacon = beacons[0]
            print("beaconMajor is \(beacon.major) and testBeaconValue called")
            self.testBeaconValue()
            }
        }
    
    func testBeaconValue(){
        if beacon.major == 55315 {
            print("within distance of beacon. Shutting off alarm")
            self.audioPlayer.stop()
            beaconManager.stopRangingBeacons(in: beaconRegion)
            }
        }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        }



    @IBAction func alarmTimeButtonPushed(_ sender: UIButton) {

        self.alarmActivated = true
        let formatter = DateFormatter()
        formatter.locale =  Locale.current
        alarmPickedTimeDate = Date()
        alarmPickedTime = DateFormatter.localizedString(from: dateAndTime, dateStyle: .short, timeStyle: .short)
    
        let currentMenu = currentMenuView
        
        dismissPicker()
        
        var pickerView: UIView?
        
        pickerView = alarmTimePickerView
        
        if let viewForPicker = pickerView , currentMenu != pickerView{
            presentPicker(viewForPicker)
        }
    }

    
 

    func presentPicker(_ menuView: UIView){
        currentMenuView = menuView
        
        UIView.animate(withDuration: 0.6, animations: { () -> Void in
            menuView.frame = CGRect(x: menuView.frame.origin.x, y: menuView.frame.origin.y - menuView.frame.height, width: menuView.frame.width, height: menuView.frame.size.height)
        }) 
    }
    
    
    func dismissPicker() {
        UIView.animate(withDuration: 1.0, animations: { () -> Void in
            if let picker = self.currentMenuView{
                self.currentMenuView = nil
                picker.frame = CGRect(x: self.view.frame.origin.x, y: self.view.frame.size.height, width: self.view.frame.size.width, height: picker.frame.height)
                }
            }) 
        }
    }



//extensions of classes below

    extension ViewController: DatePickerViewDelegate{
        func cancelPressed() {
            if let menuView = currentMenuView{
                if menuView == alarmTimePickerView{
            }
        }
        dismissPicker()
    }
    func savePressed() {
        dismissPicker()
    }
    
    func datePickerValueChanged(_ date: Date) {
        let currentDate = Date()
        var secondsTillAlarm = [date .timeIntervalSince(currentDate)]
        secondsTillAlarmFromArray = secondsTillAlarm[0]
            if secondsTillAlarmFromArray < 0 {
                    secondsTillAlarmFromArray = 86400 + secondsTillAlarmFromArray
            }
    
        print("secondsTillAlarm: \(date)")
        
        self.setTimers()
    
//    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//    appDelegate.secondsTillAlarmInterval = secondsTillAlarmFromArray

        if let menuView = currentMenuView{
            if menuView == alarmTimePickerView{
                alarmSetTime = DateFormatter.localizedString(from: date, dateStyle: .none, timeStyle: .short)
                print("alarmTime: \(alarmSetTime)")
                alarmTimeButton.setTitle(alarmSetTime, for: UIControlState())
                }
            }
        }
    
    func setTimers(){
        //notification:
        notification.fireDate = Date(timeIntervalSinceNow:secondsTillAlarmFromArray)
        notification.alertBody = "Wake Up!"
        notification.alertAction = "be awesome!"
        let sound = ("railroad_crossing_bell-") as String
        notification.soundName = sound + ".mp3"
        notification.userInfo = ["CustomField1": "w00t"]

        UIApplication.shared.scheduleLocalNotification(notification)
        //end of notification
     
        self.timer = Timer.scheduledTimer(timeInterval: self.secondsTillAlarmFromArray, target: self, selector: #selector(ViewController.playAlarmSounds), userInfo: nil, repeats: false)
        print("secondsTillAlarmFromArray: \(self.secondsTillAlarmFromArray)")
    }

    func playAlarmSounds(){
        //beaconManager.startMonitoringForRegion(beaconRegion)
        beaconManager.startRangingBeacons(in: beaconRegion)

        print("self.timer = \(self.timer.timeInterval)")
        print("playAlarmSounds in .Delegate called")
             
        //audioPlayer.prepareToPlay()
        self.timer.invalidate()
        self.audioPlayer.play()
        self.perform(#selector(ViewController.playAlarmSounds), with: nil, afterDelay: 0)
        }
    }











