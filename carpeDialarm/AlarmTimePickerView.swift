
import UIKit

protocol DatePickerViewDelegate{
    func cancelPressed()
    func savePressed()
    func datePickerValueChanged(_ date: Date)
}


class AlarmTimePickerView: UIView {


    @IBOutlet weak var alarmTimePicker: UIDatePicker!

    var delegate: DatePickerViewDelegate?
    
    @IBAction func cancelBarButtonItemPressed(_ sender: UIBarButtonItem) {
        delegate?.cancelPressed()
    }
    
    
    @IBAction func saveAlarmTimeBarButtonItemPressed(_ sender: UIBarButtonItem) {
        delegate?.savePressed()
    }
   
    
    @IBAction func datePickerChanged(_ sender: UIDatePicker) {
        delegate?.datePickerValueChanged(sender.date)
    }

}
