//
//  AlarmTimePickerView.swift
//  carpeDialarm
//
//  Created by Kevin Doherty on 5/30/16.
//  Copyright © 2016 Kevin Doherty. All rights reserved.
//

import UIKit

protocol DatePickerViewDelegate{
    func cancelPressed()
    func savePressed()
    func datePickerValueChanged(date: NSDate)
}


class AlarmTimePickerView: UIView {


    @IBOutlet weak var alarmTimePicker: UIDatePicker!

    var delegate: DatePickerViewDelegate?
    
    @IBAction func cancelBarButtonItemPressed(sender: UIBarButtonItem) {
    
        delegate?.cancelPressed()
    
    }
    
    
    
    @IBAction func saveAlarmTimeBarButtonItemPressed(sender: UIBarButtonItem) {
        delegate?.savePressed()
        
    
    }
   
    
    
    @IBAction func datePickerChanged(sender: UIDatePicker) {
        delegate?.datePickerValueChanged(sender.date)
    
    
    }






}
