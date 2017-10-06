//
//  MessageCell.swift
//  Wagel
//
//  Created by Alexandru Toma on 05/10/2017.
//  Copyright © 2017 Alexandru Toma. All rights reserved.
//

import Foundation
import UIKit

typealias Message = (from: MessageFrom, content: String)

class MessageCell: UICollectionViewCell {
    @IBOutlet weak var messageLabel: UILabel!
    
    func setupMessage(message: Message) {
        messageLabel.text = message.content
    }
    
}
