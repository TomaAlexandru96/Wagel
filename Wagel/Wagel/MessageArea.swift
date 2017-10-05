//
//  FormLogic.swift
//  Wagel
//
//  Created by Alexandru Toma on 05/10/2017.
//  Copyright © 2017 Alexandru Toma. All rights reserved.
//

import Foundation
import UIKit

class MessageArea: UITableView {
    
    var nrOfMessages: Int = 0
    var messages: [Message] = []
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        delegate = self
        dataSource = self
        resetForm(withReset: false)
    }
    
    @IBAction func refreshPressed(_ sender: Any) {
        resetForm(withReset: true)
    }
    
    func resetForm(withReset: Bool) {
        messages = []
        nrOfMessages = 0
        let job = Thread(block: {self.setupForm(withReset: withReset)})
        job.start()
    }
    
    func setupForm(withReset: Bool) {
        if (withReset) {
            sendMessage(message: (.AI, "Ok let's start again!"))
            Thread.sleep(forTimeInterval: 1)
        }
        sendMessage(message: (.AI, "Hi there! Let’s get you a price as quickly as we can… You only need to answer 7 quick questions about your pet."))
        Thread.sleep(forTimeInterval: 1)
        sendMessage(message: (.AI, "How many pets are you looking to insure?"))
    }
    
}

enum MessageFrom {
    case Me
    case AI
}

extension MessageArea: UITableViewDataSource, UITableViewDelegate {
    
    func sendMessage(message: Message) {
        nrOfMessages += 1
        messages.append(message)
        DispatchQueue.main.async(execute: reloadData)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nrOfMessages
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let otherCellID = "AIMessage"
        let meCellID = "MeMEssage"
    
        var identifier = ""
        
        if messages[indexPath.item].from == .AI {
            identifier = otherCellID
        } else {
            identifier = meCellID
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as! MessageCell? else {
            fatalError("Cell with name \(meCellID) has not been found")
        }
        
        cell.setupMessage(message: messages[indexPath.item])
        
        return cell
    }
    
}

