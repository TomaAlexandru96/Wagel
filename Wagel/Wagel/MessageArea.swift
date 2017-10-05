//
//  MainViewController.swift
//  Wagel
//
//  Created by Alexandru Toma on 05/10/2017.
//  Copyright © 2017 Alexandru Toma. All rights reserved.
//

import UIKit

class MessageArea: UITableView {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let form = FormLogic()
        
        dataSource = form
        delegate = form
    }
    
}
