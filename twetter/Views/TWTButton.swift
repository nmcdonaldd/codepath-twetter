//
//  TWTButton.swift
//  twetter
//
//  Created by Nick McDonald on 2/1/17.
//  Copyright © 2017 Nick McDonald. All rights reserved.
//

import UIKit

class TwitterFollowButton: UIButton {

    override func awakeFromNib() {
        
        self.layer.cornerRadius = 5.0
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor(red: 85.0/255.0, green: 172.0/255.0, blue: 238.0/255.0, alpha: 1.0).cgColor
        
    }

}
