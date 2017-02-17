//
//  TwetterFollowingButtonView.swift
//  twetter
//
//  Created by Nick McDonald on 2/17/17.
//  Copyright © 2017 Nick McDonald. All rights reserved.
//

import UIKit

enum TwetterFollowingButtonType {
    case following
    case notFollowing
}

class TwetterFollowingButtonView: UIButton {
    
    override func awakeFromNib() {
        self.layer.cornerRadius = 4.0
        self.layer.borderColor = defaultAppColor.cgColor
        self.layer.borderWidth = 2.0
    }
    
    func setButtonTypeWithTitle(_ type: TwetterFollowingButtonType, title: String) {
        UIView.animate(withDuration: 0.3) {
            switch type {
            case .notFollowing:
                self.backgroundColor = defaultAppColor
                self.setTitleColor(UIColor.white, for: .normal)
                self.layer.borderColor = UIColor.white.cgColor
                self.layer.borderWidth = 0.0
                break
            case .following:
                self.backgroundColor = UIColor.white
                self.setTitleColor(defaultAppColor, for: .normal)
                self.layer.borderColor = defaultAppColor.cgColor
                self.layer.borderWidth = 1.5
                break
            }
            self.setTitle(title, for: .normal)
        }
    }
}
