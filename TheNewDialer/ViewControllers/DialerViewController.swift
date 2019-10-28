//
//  DialerViewController.swift
//  TheNewDialer
//
//  Created by Chaoqun Ding on 2019-10-25.
//  Copyright © 2019 Chaoqun Ding. All rights reserved.
//

import UIKit

class DialerViewController: UIViewController {
    
    @IBOutlet weak var dialerButton: UIButton!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var digitInputTextField: UITextField!
    @IBOutlet weak var lastDigitTextField: UITextField! // not shown in UI, just for debugging
    
    @IBOutlet weak var digitOneView: UIView! // the yellow view used for highlighting digit 1 on dialler button when dialer button pressed
    @IBOutlet weak var digitTwoView: UIView! // the yellow view used for highlighting digit 2 on dialler button when dialer button pressed
    @IBOutlet weak var digitThreeView: UIView! // the yellow view used for highlighting digit 3 on dialler button when dialer button pressed
    @IBOutlet weak var digitFourView: UIView! // the yellow view used for highlighting digit 4 on dialler button when dialer button pressed
    @IBOutlet weak var digitFiveView: UIView! // the yellow view used for highlighting digit 5 on dialler button when dialer button pressed
    @IBOutlet weak var digitSixView: UIView! // the yellow view used for highlighting digit 6 on dialler button when dialer button pressed
    @IBOutlet weak var digitSevenView: UIView! // the yellow view used for highlighting digit 7 on dialler button when dialer button pressed
    @IBOutlet weak var digitEightView: UIView! // the yellow view used for highlighting digit 8 on dialler button when dialer button pressed
    @IBOutlet weak var digitNineView: UIView! // the yellow view used for highlighting digit 9 on dialler button when dialer button pressed
    @IBOutlet weak var digitZeroView: UIView! // the yellow view used for highlighting digit 0 on dialler button when dialer button pressed
    
    @IBOutlet weak var eraseLastDigitButton: UIButton! // invisible, and covered the digit input text filed in UI, used for erasing the last digit in the text field when tapped
    
    var timer = Timer()
    // var isTimerRunning = true
    var longgesture = UILongPressGestureRecognizer() // recognize if button is long pressed, in this code, it used for recgnizing if call button is long pressed
    var digitViews: [UIView] = [] // UIView container
    
    override func viewDidLoad() { // this function works similar as main() in cpp
        
        lastDigitTextField.isHidden = true
        lastDigitTextField.isUserInteractionEnabled = false
        digitInputTextField.isUserInteractionEnabled = false // disable user interaction with digit input text field, (as mensioned above, we use eraseLastDigitButton which covers the text field to erase the last digit)
        
        digitViews = [digitZeroView, digitOneView, digitTwoView, digitThreeView, digitFourView, digitFiveView, digitSixView, digitSevenView, digitEightView, digitNineView]
        
        circleShapedViews(digitViews)
        hideAllDigitViews(digitViews)
//        digitOneView.backgroundColor = UIColor.systemYellow.withAlphaComponent(0.5)
        dismissKeyboard() // make sure no keyboard shown in dialer page
        // initial state
        callButton.isHidden = true
        callButton.isUserInteractionEnabled = false
        dialerButton.isHidden = false
        dialerButton.isUserInteractionEnabled = true

        dialerButton.addTarget(self, action: #selector(runTimer), for: .touchDown)
        dialerButton.addTarget(self, action: #selector(stopIncrement), for: .touchUpInside)
        super.viewDidLoad()

        longgesture = UILongPressGestureRecognizer(target: self, action: #selector(self.longPressDetect))
        longgesture.minimumPressDuration = 2
        callButton.addGestureRecognizer(longgesture)
        //runTimer()
    }
    
    // MARK: Helper Functions (testing)
    
    func dismissKeyboard() { // hide system keyboard
        self.view.endEditing(false)
    }

    var lastDigit = 0
    var dialerButtonReleasedTime = 0


    
    func circleShapedViews(_ allDigitViews: [UIView]) { // make all view in the called UIView container shape in a circle
        for i in 0...9 {
            var myView = allDigitViews[i]
            myView.layer.cornerRadius = myView.frame.size.width/2
            myView.clipsToBounds = true
            
        }
    }
    
    func hideAllDigitViews(_ allDigitViews: [UIView]) { // hight all highlight of digits on dialer button
        for i in 0...9 {
            digitOpacityOff(allDigitViews[i])
        }
    }
    
    func digitOpacityOn(_ digitNumberView: UIView) { // make the UIView half transparent, displays as a highlight
        digitNumberView.isHidden = false
        digitNumberView.backgroundColor = UIColor.systemYellow.withAlphaComponent(0.5)
    }
    
    func digitOpacityOff(_ digitNumberView: UIView) { // hide all highlights
        digitNumberView.isHidden = true
    }
    
    @objc func lastDigitIncrement() { // digit increment and show the increment digit as the last digit on digit input text field
        //digitOpacityOff(digitViews[lastDigit+1])
        hideAllDigitViews(digitViews)
        if lastDigit == 9 {
            lastDigit = 0
        } else {
            lastDigit += 1
        }
        print(lastDigit)
        lastDigitTextField.text = String(lastDigit)
        digitOpacityOn(digitViews[lastDigit])
        
    }
    
    @objc func stopIncrement() { // when dialer button released
        //isTimerRunning = false
        print("stop increment")
        timer.invalidate() // stop timer, to do so, can ensure there is only one timer running when dialer button pressed down
        dialerButtonReleasedTime += 1
        if digitInputTextField.text?.count == dialerButtonReleasedTime - 1 {
            digitInputTextField.insertText(String(lastDigit)) // insert the last digit on text field
        }
        hideAllDigitViews(digitViews) // when dialer button released, all highlights of digits should be hidden
        var currentString = digitInputTextField.text // current digits (as a string) displayed on text field
        var lengthOfCurrentString = currentString?.count // number of digits displayed on text field
        if lengthOfCurrentString == 10 { // when number of digits displayed on text field reaches 10, dialer button hidden, call button displayed
            dialerButton.isHidden = true
            dialerButton.isUserInteractionEnabled = false
            callButton.isHidden = false
            callButton.isUserInteractionEnabled = true
        }
    }

    @objc func runTimer() {
        lastDigit = 0 // initialize of lastDigit, this value (0) is also the default digit displayed when user pressed button less than 1 second. (changing this value may cause error (index out of range), if that happens, debug in function lastDigitIncrement())
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: (#selector(self.lastDigitIncrement)), userInfo: nil, repeats: true) // 0.5 is the time interval between increment digits, modify to see difference
    }

    
    // MARK: IBActions
    
    @IBAction func eraseLastDigitButtonTapped(_ sender: Any) {
        removeLastDigitInTextField()
    }
    
    func removeLastDigitInTextField() {
        var currentString = digitInputTextField.text
        var currentLengthOfDigits = currentString?.count
        if currentLengthOfDigits != 0 {
            var newString = String((currentString?.prefix(currentLengthOfDigits!-1))!)
            digitInputTextField.text = newString
            dialerButtonReleasedTime -= 1
        }
        currentString = digitInputTextField.text
        var lengthOfCurrentString = currentString?.count
        if lengthOfCurrentString != 10 { // after tapped the textfield, if number of digits is not equal to 10, call button hidden, dialer button displayed
            dialerButton.isHidden = false
            dialerButton.isUserInteractionEnabled = true
            callButton.isHidden = true
            callButton.isUserInteractionEnabled = false
        }
       
    }
    
    @objc func longPressDetect(_ sender: UILongPressGestureRecognizer) {
        // call
        dismissKeyboard()
        let alertController = UIAlertController(title: "Long Press Of Call Button Detected", message: "Calling", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default,handler: nil))
        present(alertController, animated: true, completion: nil)
    }
}


