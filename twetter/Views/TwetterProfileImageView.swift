//
//  TwetterProfileImageView.swift
//  twetter
//
//  Created by Nick McDonald on 2/13/17.
//  Copyright © 2017 Nick McDonald. All rights reserved.
//

import UIKit

class TwetterProfileImageView: UIImageView {
    
    override func awakeFromNib() {
        self.layer.cornerRadius = 10.0
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.borderWidth = 3.0
    }
}
