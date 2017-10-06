//
//  MessageCell.swift
//  Wagel
//
//  Created by Alexandru Toma on 05/10/2017.
//  Copyright © 2017 Alexandru Toma. All rights reserved.
//

import UIKit

typealias Message = (from: MessageFrom, content: String)

class MessageCell: UICollectionViewCell {
    
    @IBOutlet weak var textLabel: UITextView!
    
    func setupMessage(message: Message) {
        textLabel.text = message.content
    }
    
}
