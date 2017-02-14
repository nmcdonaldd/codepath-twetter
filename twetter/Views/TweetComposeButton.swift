//
//  TweetComposeButton.swift
//  twetter
//
//  Created by Nick McDonald on 2/11/17.
//  Copyright © 2017 Nick McDonald. All rights reserved.
//

import UIKit

// Custom UIButton that will change the alpha based on enabled or not.

class TweetComposeButton: UIButton {
    
    override var isEnabled: Bool {
        willSet(enabled) {
            if (enabled) {
                self.alpha = 1.0
            } else {
                self.alpha = 0.7
            }
        }
    }
    
    override func awakeFromNib() {
        self.layer.cornerRadius = 4.0
        self.clipsToBounds = true
    }
}
