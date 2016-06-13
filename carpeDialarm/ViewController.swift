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

class ViewController: UIViewController,CLLocationManagerDelegate ,ESTBeaconManagerDelegate,AVAudioPlayerDelegate {

   
    @IBOutlet weak var alarmTimeButton: UIButton!
    
    @IBOutlet weak var alarmOnOffSwitch: UISwitch!
    
    @IBOutlet var alarmTimePickerView: AlarmTimePickerView!
    
    var dateAndTime = NSDate()
    
    var alarmPickedTimeDate = NSDate()
    
    var buttonStartTime = NSDate()
    
    var alarmSetTime = String()
    
    var alarmSetTimeShortDateStyle = String()
    
    var currentMenuView: UIView?
    
    var convertedDate = String()
    
    var alarmPickedTime = String()
    
    var alarmActivated = Bool()
    
    var systemSoundID = SystemSoundID()
    
    let beaconManager: ESTBeaconManager = ESTBeaconManager()
    
    var beaconRegion: CLBeaconRegion = CLBeaconRegion()
    
    let locationManager = CLLocationManager()
    
    var secondsTillAlarmFromArray = NSTimeInterval()
    
    var timeIntervalTillAlarmForDelegate = NSTimeInterval()
    
    var audioPlayer: AVAudioPlayer = AVAudioPlayer()
    
    //var session:AVAudioSession = AVAudioSession.sharedInstance()
    
    var timer = NSTimer()
    
    //var audioFileName = String()
    
    //var soundURL = NSObject()
    
    //var sound = NSURL()

override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    
        let formatter = NSDateFormatter()
        formatter.locale =  NSLocale.currentLocale()
        buttonStartTime = NSDate()
        alarmSetTime = NSDateFormatter.localizedStringFromDate(buttonStartTime, dateStyle: .NoStyle, timeStyle: .ShortStyle)
    
        alarmTimeButton.setTitle(alarmSetTime, forState: UIControlState.Normal)
        alarmTimeButton.layer.cornerRadius = 10
    
        alarmTimePickerView.frame = CGRectMake(view.frame.origin.x, view.frame.height, view.frame.width, alarmTimePickerView.frame.height)
        alarmTimePickerView.delegate = self
        view.addSubview(alarmTimePickerView)
        let timer = NSTimer()
        print("the current time at view did load is NSDate \(dateAndTime)" )
    
    
        self.locationManager.delegate = self
        self.locationManager.requestAlwaysAuthorization()
        //self.locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        self.locationManager.allowsBackgroundLocationUpdates = true
    
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
        soundURL = NSBundle.mainBundle().pathForResource(audioFileName, ofType: "mp3")!
        var sound = NSURL()
        sound = NSURL(fileURLWithPath: soundURL as! String)
        //AudioServicesPlayAlertSound(1005)
        //audioPlayer = AVPlayer(URL: sound!)

        do {
                self.audioPlayer = try AVAudioPlayer(contentsOfURL: sound)
                print("audioPlayer = try AVAudioPlayer(contentsOfURL: sound!)")
            
        }
        catch{
            
        }
            self.audioPlayer.prepareToPlay()
            self.audioPlayer.delegate = self
            print("AVAudioSession is set to railroad")
    
        beaconManager.delegate = self
        self.beaconManager.requestAlwaysAuthorization()
        beaconRegion = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")!, major: 42673, minor: 123, identifier: "alarmBeacon region")
        beaconRegion.notifyOnEntry = true
        beaconRegion.notifyOnExit = false
        beaconManager.startMonitoringForRegion(beaconRegion)
        self.locationManager.startUpdatingLocation()
}


//func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        
//         //print("locations object at index 0: \(locations [0])")
//     if (self.locationManager.allowsBackgroundLocationUpdates == true){
//        print("self.locationManager.allowsBackgroundLocationUpdates = TRUE")
//    }
//    
//    var status = CLLocationManager.authorizationStatus()
//    if (status == CLAuthorizationStatus.NotDetermined) {
//        print("status not determined")
//        
//    }
//    else if (status == CLAuthorizationStatus.AuthorizedAlways) {
//        print("status authorized always")
//        
//    }
//    else if (status == CLAuthorizationStatus.AuthorizedWhenInUse) {
//        print("status not authorized when in use")
//        
//    }
//    else if (status == CLAuthorizationStatus.Denied) {
//        print("status denied")
//        
//    }
//    
//    }

func beaconManager(manager: AnyObject, didEnterRegion region: CLBeaconRegion) {
        print("entered the region" )
        //var viewController = ViewController()
        self.alarmActivated = false
        
        let notification = UILocalNotification()
        notification.alertBody = "Shutting Off Alarm" + "Have a great day"
        UIApplication.sharedApplication().presentLocalNotificationNow(notification)
    }


func beaconManager(manager: AnyObject, didExitRegion region: CLBeaconRegion) {
        print("exited the region")
    }
    
func beaconManager(manager: AnyObject, monitoringDidFailForRegion region: CLBeaconRegion?, withError error: NSError) {
        print("region did fail \(manager) \(region) \(error)")
    }

    func beaconManager(manager: AnyObject, didStartMonitoringForRegion region: CLBeaconRegion) {
        
        print("did start monitoring region")
    }
    
//  ALARM FUNCTIONS:

    
//Step 1: Get current time
//func getDateAndTime() {
//    alarmSetTimeShortDateStyle = NSDateFormatter.localizedStringFromDate(dateAndTime, dateStyle: .ShortStyle, timeStyle: .ShortStyle)
//    print("alarmSetTimeShortDateStyle: \(alarmSetTimeShortDateStyle)")
//    
//    let formatter = NSDateFormatter()
//    formatter.locale =  NSLocale.currentLocale()
//    dateAndTime = NSDate()
//    convertedDate = NSDateFormatter.localizedStringFromDate(dateAndTime, dateStyle: .NoStyle, timeStyle: .ShortStyle)
//    
//    print(convertedDate)
//    
//    self.alarmCheckActivate()
//    
//    self.performSelector("getDateAndTime", withObject: nil, afterDelay: 1)
//}

//Step 2: See if the current time equals the time that the alarm is set for
//func alarmCheckActivate(){
//        if self.alarmActivated == true{
//            print("alarm time is \(alarmSetTime) and convertedDate is \(convertedDate)")
//            print("alarmSetTimeLongStyle is \(alarmSetTimeShortDateStyle) and alarmPickedTime is \(alarmPickedTime)")
//            if alarmSetTime == convertedDate && alarmSetTimeShortDateStyle != alarmPickedTime{
//                self.playAlarmSounds()
//            }
//        }
//    }
//    

//Step 3: Play alarm sound if the current time is equal to the alarm time
//func playAlarmSounds(){
//    if self.alarmActivated == true{
//        
//        do {
//            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
//        }
//        catch {
//            // report for an error
//        }
//        
//        systemSoundID = 1304
//        AudioServicesPlaySystemSound (systemSoundID)
//        self.performSelector("playAlarmSounds", withObject: nil, afterDelay: 1)
//    }
//}

    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
}



@IBAction func alarmTimeButtonPushed(sender: UIButton) {

        self.alarmActivated = true
        let formatter = NSDateFormatter()
        formatter.locale =  NSLocale.currentLocale()
        alarmPickedTimeDate = NSDate()
        alarmPickedTime = NSDateFormatter.localizedStringFromDate(dateAndTime, dateStyle: .ShortStyle, timeStyle: .ShortStyle)
    
        let currentMenu = currentMenuView
        
        dismissPicker()
        
        var pickerView: UIView?
        
        pickerView = alarmTimePickerView
        
        if let viewForPicker = pickerView where currentMenu != pickerView{
            presentPicker(viewForPicker)
        }
}


@IBAction func alarmOnOffSwitchTouched(sender: UISwitch) {
   
    //self.alarmActivated = false

}
    
 

func presentPicker(menuView: UIView){
        
        currentMenuView = menuView
        
        UIView.animateWithDuration(0.6) { () -> Void in
            menuView.frame = CGRectMake(menuView.frame.origin.x, menuView.frame.origin.y - menuView.frame.height, menuView.frame.width, menuView.frame.size.height)
        }
        
}
    
    
func dismissPicker() {
        UIView.animateWithDuration(1.0) { () -> Void in
            if let picker = self.currentMenuView{
                
                self.currentMenuView = nil
                
                picker.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.size.height, self.view.frame.size.width, picker.frame.height)
            }
        }
    }
    



}



//extensions of classes below

extension ViewController: DatePickerViewDelegate
    
{
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
    
func datePickerValueChanged(date: NSDate) {
    var currentDate = NSDate()
    
    var secondsTillAlarm = [date .timeIntervalSinceDate(currentDate)]
    
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
                alarmSetTime = NSDateFormatter.localizedStringFromDate(date, dateStyle: .NoStyle, timeStyle: .ShortStyle)

                
                print("alarmTime: \(alarmSetTime)")

                alarmTimeButton.setTitle(alarmSetTime, forState: UIControlState.Normal)
            }
        }
    }
    
func setTimers(){
    //notification:
    
    
    let notification = UILocalNotification()
    notification.fireDate = NSDate(timeIntervalSinceNow:secondsTillAlarmFromArray)
    notification.alertBody = "Wake Up!"
    notification.alertAction = "be awesome!"
    let sound = ("railroad_crossing_bell-") as String
    notification.soundName = sound + ".mp3"
    notification.userInfo = ["CustomField1": "w00t"]
//
//    UIApplication.sharedApplication().scheduleLocalNotification(notification)
//    //end of notification
//    
     self.timer = NSTimer.scheduledTimerWithTimeInterval(self.secondsTillAlarmFromArray, target: self, selector: Selector("playAlarmSounds"), userInfo: nil, repeats: false)
    
    print("secondsTillAlarmFromArray: \(self.secondsTillAlarmFromArray)")
    
    }

func playAlarmSounds(){
        print("self.timer = \(self.timer.timeInterval)")
        print("playAlarmSounds in .Delegate called")

        //audioPlayer.prepareToPlay()
        self.timer.invalidate()
        self.audioPlayer.play()

        //self.performSelector("playAlarmSounds", withObject: nil, afterDelay: 1)
    }

}











