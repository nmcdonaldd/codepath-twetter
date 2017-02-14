//
//  BaseTwetterImageView.swift
//  twetter
//
//  Created by Nick McDonald on 2/13/17.
//  Copyright © 2017 Nick McDonald. All rights reserved.
//

import UIKit

class BaseTwetterImageView: UIImageView {
    
    override func awakeFromNib() {
        self.layer.cornerRadius = 4.0
        self.clipsToBounds = true
        self.contentMode = .scaleAspectFill
    }
    
}
