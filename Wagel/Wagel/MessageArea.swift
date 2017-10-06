//
//  FormLogic.swift
//  Wagel
//
//  Created by Alexandru Toma on 05/10/2017.
//  Copyright © 2017 Alexandru Toma. All rights reserved.
//

import UIKit

class Form: NSObject {
    private var petsNumber: Int = 0
    
    func fillInPetsNumber(input: String) -> Bool {
        guard let nr = Int(input) else {
            return false
        }
        petsNumber = nr
        return true
    }
}

class MessageArea: UICollectionViewController {
    
    var nrOfMessages: Int = 0
    var messages: [Message] = []
    var job: Thread?
    var form: Form = Form()
    var input: String = ""
    var waitingType: AnyClass?
    let messageSema: DispatchSemaphore = DispatchSemaphore(value: 1)
    let inputSema: DispatchSemaphore = DispatchSemaphore(value: 0)
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
            
            while !self.form.fillInPetsNumber(input: self.awaitInput()) {
                usleep(self.WAIT_TIME_SHORT)
                self.sendMessage(message: (.AI, "I am not sure I understand can you please answer again the previous question."))
            }
            
            usleep(self.WAIT_TIME_SHORT)
            self.sendMessage(message: (.AI, "Cool!"))
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

