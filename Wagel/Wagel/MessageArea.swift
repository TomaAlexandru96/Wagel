//
//  FormLogic.swift
//  Wagel
//
//  Created by Alexandru Toma on 05/10/2017.
//  Copyright © 2017 Alexandru Toma. All rights reserved.
//

import UIKit

class Form: NSObject {
    var petsNumber: Int = 0
}

class MessageArea: UICollectionViewController {
    
    var nrOfMessages: Int = 0
    var messages: [Message] = []
    var job: Thread?
    var form: Form = Form()
    var input: String = ""
    let messageSema: DispatchSemaphore = DispatchSemaphore(value: 1)
    let formSema: DispatchSemaphore = DispatchSemaphore(value: 1)
    let inputSema: DispatchSemaphore = DispatchSemaphore(value: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resetForm(withReset: false)
    }
    
    func resetForm(withReset: Bool) {
        messages = []
        nrOfMessages = 0
        self.setupForm(withReset: withReset)
    }
    
    func setupForm(withReset: Bool) {
        job?.cancel()
        job = Thread() {
            self.formSema.wait()
            self.form = Form()
            if withReset {
                self.sendMessage(message: (.AI, "Ok let's start again!"))
                sleep(1)
            }
            self.sendMessage(message: (.AI, "Hi there! Let’s get you a price as quickly as we can… You only need to answer 7 quick questions about your pet."))
            sleep(1)
            self.sendMessage(message: (.AI, "How many pets are you looking to insure?"))
            
            self.form.petsNumber = Int(self.awaitInput())!
            sleep(1)
            self.sendMessage(message: (.AI, "Cool!"))
            self.formSema.signal()
            self.job = nil
        }
        job?.start()
    }
    
    func awaitInput() -> String {
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

