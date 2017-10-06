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
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardChange),
                                               name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        textInput.delegate = self
        messageArea?.delegate = self
    }
    
    @objc func keyboardChange(notification: NSNotification) {
        let keyboardSize = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! CGRect).size
        if view.frame.minY >= 0 {
            rescaleView(movement: -keyboardSize.height)
        } else {
            rescaleView(movement: keyboardSize.height)
        }
    }
    
    func rescaleView(movement: CGFloat) {
        view.frame.origin.y += movement
        messageArea?.view.frame.origin.y -= movement
        messageArea?.view.frame.size.height += movement
        messageArea?.scrollToBottom()
    }
    
    func animateTextField(movement: CGFloat, time: TimeInterval) {
        UIView.animate(withDuration: time, animations: {self.textInput.frame.origin.y += movement}, completion: nil)
    }
    
    @IBAction func pressedRefresh(_ sender: UIBarButtonItem) {
        messageArea?.resetForm(withReset: true)
        textInput.resignFirstResponder()
    }
    
    @IBAction func pressedSend(_ sender: UIButton) {
        if let input = textInput.text, input != "" {
            messageArea?.sendMessage(message: (.Me, input))
            textInput.resignFirstResponder()
            textInput.text = ""
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? MessageArea, segue.identifier == "MessagesSegue" {
            messageArea = dest
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let input = textInput.text, input != "" {
            messageArea?.sendMessage(message: (.Me, input))
            textField.resignFirstResponder()
            textField.text = ""
            return true
        }
        return false
    }
    
}

extension MainView: MessageAreaDelegate {
    func changeKeyboard(type: UIKeyboardType) {
        textInput.keyboardType = type
    }
}
