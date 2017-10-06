//
//  MainView.swift
//  Wagel
//
//  Created by Alexandru Toma on 06/10/2017.
//  Copyright © 2017 Alexandru Toma. All rights reserved.
//

import UIKit
import Foundation

class MainView: UIViewController {
    
    @IBOutlet weak var inputArea: UIView!
    @IBOutlet weak var textInput: UITextField!
    @IBOutlet weak var petNumberView: UIView!
    @IBOutlet weak var petNumberPicker: UIPickerView!
    
    var messageArea: MessageArea?
    var inputs: [UIView] = []
    var petsPicker: PetsPicker!
    var nameField: NameField!
    var catOrDogPicker: CatOrDogPicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardChange),
                                               name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        messageArea?.delegate = self
        
        inputs = [petNumberView, textInput]
        resetViews()
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? MessageArea, segue.identifier == "MessagesSegue" {
            messageArea = dest
        }
    }
    
    fileprivate func resetViews() {
        inputs.forEach {view in
            DispatchQueue.main.async {
                view.isHidden = true
            }
        }
    }
    
    fileprivate func show(view: UIView) {
        DispatchQueue.main.async {
            view.isHidden = false
        }
    }
    
}

extension MainView: MessageAreaDelegate {
    
    func changeInputToPetsNumber() {
        resetViews()
        show(view: self.inputs[0])
        petsPicker = (PetsPicker()).setView(main: self)
        DispatchQueue.main.async {
            self.petNumberPicker.dataSource = self.petsPicker
            self.petNumberPicker.delegate = self.petsPicker
        }
    }
    
    func changeInputToPetName() {
        resetViews()
        show(view: self.inputs[1])
        textInput.keyboardType = UIKeyboardType.default
        nameField = (NameField()).setView(main: self)
        DispatchQueue.main.async {
            self.textInput.delegate = self.nameField
        }
    }
    
    func changeInputToAnimal() {
        resetViews()
        show(view: self.inputs[0])
        catOrDogPicker = CatOrDogPicker()
        DispatchQueue.main.async {
            self.petNumberPicker.dataSource = self.catOrDogPicker
            self.petNumberPicker.reloadAllComponents()
        }
    }
    
    func changeInputToAge() {
    }
    
    func changeInputToGender() {
    }
    
    func changeInputToBreed() {
    }
    
    func changeInputToAddress() {
    }
    
}

extension MainView {
    
    @IBAction func pressedRefresh(_ sender: UIBarButtonItem) {
        messageArea?.resetForm(withReset: true)
        view.resignFirstResponder()
        resetViews()
    }
    
    @IBAction func pressedSubmitInPicker(_ sender: UIButton) {
        petsPicker.choose()
    }
    
}

class PetsPicker: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
    
    fileprivate var main: MainView!
    private var selected: String = "1"
    
    func choose() {
        main.messageArea?.sendMessage(message: (.Me, selected))
        main.resetViews()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(row + 1)"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selected = "\(row + 1)"
    }
    
    func setView(main: MainView) -> PetsPicker {
        self.main = main
        return self
    }
    
}

class NameField: NSObject, UITextFieldDelegate {
    
    fileprivate var main: MainView!
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let input = textField.text, input != "" {
            main.messageArea?.sendMessage(message: (.Me, input))
            textField.resignFirstResponder()
            textField.text = ""
            return true
        }
        return false
    }
    
    func setView(main: MainView) -> NameField {
        self.main = main
        return self
    }
    
}

class CatOrDogPicker: NSObject, UIPickerViewDataSource  {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        print("Here")
        switch row {
        case 0:
            return "Cat"
        case 1:
            return "Dog"
        default:
            return ""
        }
    }
    
}
