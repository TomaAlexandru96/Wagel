//
//  FormLogic.swift
//  Wagel
//
//  Created by Alexandru Toma on 05/10/2017.
//  Copyright © 2017 Alexandru Toma. All rights reserved.
//

import Foundation
import UIKit

class FormLogic: NSObject {
    
    typealias Message = (from: MessageFrom, content: String)
    var nrOfMessages: Int = 2
    var messages: [Message] = [
        (.Other, "Hello"),
        (.Other, "How are you?")
    ]
    
    func sendMessage(message: Message) {
        self.nrOfMessages += 1
        self.messages.append(message)
    }
    
}

enum MessageFrom {
    case Me
    case Other
}

extension FormLogic: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("row")
        return nrOfMessages
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let otherCellID = "Message"
        
        if messages[indexPath.count].from == .Other {
            print("Other")
        } else {
            print("Me")
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: otherCellID) else {
            fatalError("Cell with name \(otherCellID) has not been found")
        }
        
        return cell
    }
    
}
