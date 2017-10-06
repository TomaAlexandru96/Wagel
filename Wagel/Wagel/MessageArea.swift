//
//  FormLogic.swift
//  Wagel
//
//  Created by Alexandru Toma on 05/10/2017.
//  Copyright © 2017 Alexandru Toma. All rights reserved.
//

import UIKit

class Form: NSObject {
    fileprivate var petsNumber: Int = 0
    fileprivate var petName: String = ""
    fileprivate var petAnimal: String = ""
    fileprivate var petGender: String = ""
    fileprivate var petAge: String = ""
    fileprivate var petBreed: String = ""
    fileprivate var petAddress: String = ""
    
    func fillInPetsNumber(input: String) -> Bool {
        guard let nr = Int(input) else {
            return false
        }
        petsNumber = nr
        return true
    }
    
    func fillInPetName(input: String) -> Bool {
        petName = input
        return true
    }
    
    func fillInPetAnimal(input: String) -> Bool {
        petAnimal = input
        return true
    }
    
    func fillInGender(input: String) -> Bool {
        petGender = input
        return true
    }
    
    func fillInPetAge(input: String) -> Bool {
        petAge = input
        return true
    }
    
    func fillInPetBreed(input: String) -> Bool {
        petBreed = input
        return true
    }
    
    func fillInPetAddress(input: String) -> Bool {
        petAddress = input
        return true
    }
    
    func getFulDescription() -> String {
        let desc = "petsNumber: \(petsNumber), petName: \(petName), petAnimal: \(petAnimal), petAge: \(petAge), petGender: \(petGender), petBreed: \(petBreed), petAddress: \(petAddress)"
        
        return desc
    }
}

protocol MessageAreaDelegate {
    func changeInputToPetsNumber()
    func changeInputToPetName()
    func changeInputToAnimal()
    func changeInputToGender()
    func changeInputToAge()
    func changeInputToBreed()
    func changeInputToAddress()
}

class MessageArea: UICollectionViewController {
    
    var nrOfMessages: Int = 0
    var messages: [Message] = []
    var job: Thread?
    var form: Form = Form()
    var input: String = ""
    var waitingType: AnyClass?
    var delegate: MessageAreaDelegate?
    var inputSema: DispatchSemaphore = DispatchSemaphore(value: 0)
    let messageSema: DispatchSemaphore = DispatchSemaphore(value: 1)
    let WAIT_TIME_SHORT: UInt32 = 500000
    let WAIT_TIME_LONG: UInt32 = 1000000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resetForm(withReset: false)
    }
    
    func resetForm(withReset: Bool) {
        job?.cancel()
        messages = []
        nrOfMessages = 0
        inputSema = DispatchSemaphore(value: 0)
        self.setupForm(withReset: withReset)
    }
    
    func setupForm(withReset: Bool) {
        job = Thread() {
            self.form = Form()
            if withReset {
                self.sendMessage(message: (.AI, "Ok let's start again!"))
                usleep(self.WAIT_TIME_LONG)
            }
            self.sendMessage(message: (.AI, "Hi there! Let’s get you a price as quickly as we can… You only need to answer 7 quick questions about your pet."))
            
            usleep(self.WAIT_TIME_LONG)
            self.sendMessage(message: (.AI, "How many pets are you looking to insure?"))
            self.delegate?.changeInputToPetsNumber()
            while !self.form.fillInPetsNumber(input: self.awaitInput()) {
                usleep(self.WAIT_TIME_SHORT)
                self.sendMessage(message: (.AI, "I am not sure I understand can you please answer again the previous question."))
            }
            
            usleep(self.WAIT_TIME_SHORT)
            self.sendMessage(message: (.AI, "Great, what is your pet’s name?"))
            self.delegate?.changeInputToPetName()
            while !self.form.fillInPetName(input: self.awaitInput()) {
                usleep(self.WAIT_TIME_SHORT)
                self.sendMessage(message: (.AI, "I am not sure I understand can you please answer again the previous question."))
            }
            
            usleep(self.WAIT_TIME_SHORT)
            self.sendMessage(message: (.AI, "Awesome name! is \(self.form.petName) a dog or a cat?"))
            self.delegate?.changeInputToAnimal()
            while !self.form.fillInPetAnimal(input: self.awaitInput()) {
                usleep(self.WAIT_TIME_SHORT)
                self.sendMessage(message: (.AI, "I am not sure I understand can you please answer again the previous question."))
            }
            
            usleep(self.WAIT_TIME_SHORT)
            self.sendMessage(message: (.AI, "And is \(self.form.petName) a girl or a boy?"))
            self.delegate?.changeInputToGender()
            while !self.form.fillInGender(input: self.awaitInput()) {
                usleep(self.WAIT_TIME_SHORT)
                self.sendMessage(message: (.AI, "I am not sure I understand can you please answer again the previous question."))
            }
            
            usleep(self.WAIT_TIME_SHORT)
            self.sendMessage(message: (.AI, "How old is \(self.form.petName)?"))
            self.delegate?.changeInputToAge()
            while !self.form.fillInPetAge(input: self.awaitInput()) {
                usleep(self.WAIT_TIME_SHORT)
                self.sendMessage(message: (.AI, "I am not sure I understand can you please answer again the previous question."))
            }
            
            usleep(self.WAIT_TIME_SHORT)
            self.sendMessage(message: (.AI, "What type of breed?"))
            self.delegate?.changeInputToBreed()
            while !self.form.fillInPetBreed(input: self.awaitInput()) {
                usleep(self.WAIT_TIME_SHORT)
                self.sendMessage(message: (.AI, "I am not sure I understand can you please answer again the previous question."))
            }
            
            usleep(self.WAIT_TIME_SHORT)
            self.sendMessage(message: (.AI, "Lastly, where do you and \(self.form.petName) live?"))
            self.delegate?.changeInputToAddress()
            while !self.form.fillInPetAddress(input: self.awaitInput()) {
                usleep(self.WAIT_TIME_SHORT)
                self.sendMessage(message: (.AI, "I am not sure I understand can you please answer again the previous question."))
            }
            
            usleep(self.WAIT_TIME_SHORT)
            self.sendMessage(message: (.AI, "Great, I’ve got everything I need. You ready to see your price now."))
            usleep(self.WAIT_TIME_SHORT)
            self.sendMessage(message: (.AI, "Pet: \(self.form.getFulDescription())"))
            
            self.job = nil
        }
        job?.start()
    }
    
    func awaitInput() -> String{
        inputSema.wait()
        return input
    }
    
    func sendMessage(message: Message) {
        messageSema.wait()
        nrOfMessages += 1
        messages.append(message)
        DispatchQueue.main.async(execute: {
            self.collectionView?.reloadData()
            if message.from == .Me {
                self.input = message.content
                self.inputSema.signal()
            }
            self.scrollToBottom()
            self.messageSema.signal()
        })
    }
    
}

enum MessageFrom {
    case Me
    case AI
}

extension MessageArea {
    
    func scrollToBottom() {
        //collectionView?.scrollToItem(at: IndexPath(item: nrOfMessages - 1, section: 0),
        //                            at: UICollectionViewScrollPosition.top, animated: true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return nrOfMessages
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let otherCellID = "AIMessage"
        let meCellID = "MeMessage"
        var identifier = ""
        
        if messages[indexPath.item].from == .AI {
            identifier = otherCellID
        } else {
            identifier = meCellID
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! MessageCell
        cell.setupMessage(message: messages[indexPath.item])
        
        return cell
    }
    
}

@IBDesignable
class MessageAreaLayout: UICollectionViewFlowLayout {
    
    override init() {
        super.init()
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        estimatedItemSize = UICollectionViewFlowLayoutAutomaticSize
    }
}

