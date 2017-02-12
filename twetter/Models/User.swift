//
//  User.swift
//  twetter
//
//  Created by Nick McDonald on 1/29/17.
//  Copyright © 2017 Nick McDonald. All rights reserved.
//

import UIKit

class User: NSObject {
    
    var name: String?
    var username: String?
    var tagline: String?
    var profileURL: URL?
    var cachedProfileImage: UIImage?
    
    var originalDicitonary: NSDictionary?
    
    init(userDictionary: NSDictionary) {
        self.originalDicitonary = userDictionary
        self.name = userDictionary["name"] as? String
        self.username = userDictionary["screen_name"] as? String
        self.tagline = userDictionary["description"] as? String
        let profileImgURL: String? = userDictionary["profile_image_url_https"] as? String
        if let profileImgURL = profileImgURL {
            self.profileURL = URL(string: profileImgURL)
        }
    }
    
    func setCachedProfileImage(image: UIImage) {
        guard self.cachedProfileImage != nil else {
            self.cachedProfileImage = image
            return
        }
    }
    
    static private var _currentUser: User?
    
    class var currentUser: User? {
        get {
            if _currentUser == nil {
                let defaults = UserDefaults.standard
                
                let userData = defaults.object(forKey: "currentUser") as? Data
                
                if let userData = userData {
                    let dictionary = try! JSONSerialization.jsonObject(with: userData, options: []) as! NSDictionary
                    _currentUser = User(userDictionary: dictionary)
                    
                }
            }
            return _currentUser
        }
        set(user) {
            _currentUser = user
            let defaults = UserDefaults.standard
            
            if let user = user {
                let data = try! JSONSerialization.data(withJSONObject: user.originalDicitonary as Any, options: [])
                defaults.set(data, forKey: "currentUser")
            } else {
                defaults.set(nil, forKey: "currentUser")
            }
            
            defaults.synchronize()
        }
    }
}
