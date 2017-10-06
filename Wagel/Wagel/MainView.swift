//
//  MainView.swift
//  Wagel
//
//  Created by Alexandru Toma on 06/10/2017.
//  Copyright © 2017 Alexandru Toma. All rights reserved.
//

import UIKit
import Foundation

class MainView: UIViewController, UITextFieldDelegate {
    
    var messageArea: MessageArea?
    @IBOutlet weak var textInput: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardUp),
                                               name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDown),
                                               name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        textInput.delegate = self
    }
    
    @objc func keyboardUp(notification: NSNotification) {
        let keyboardSize = (notification.userInfo![UIKeyboardFrameBeginUserInfoKey] as! CGRect)
        animateTextField(movement: -keyboardSize.height,
                         time: notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! TimeInterval)
    }
    
    @objc func keyboardDown(notification: NSNotification) {
        let keyboardSize = (notification.userInfo![UIKeyboardFrameBeginUserInfoKey] as! CGRect)
        animateTextField(movement: keyboardSize.height,
                         time: notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! TimeInterval)
    }
    
    func animateTextField(movement: CGFloat, time: TimeInterval) {
        UIView.animate(withDuration: time, animations: {self.textInput.frame.origin.y += movement}, completion: nil)
    }
    
    @IBAction func pressedRefresh(_ sender: UIBarButtonItem) {
        messageArea?.resetForm(withReset: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? MessageArea, segue.identifier == "MessagesSegue" {
            messageArea = dest
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let textInput = textInput.text, textInput != "" {
            messageArea?.sendMessage(message: (.Me, textInput))
        }
        textInput.text = ""
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true;
    }
}
