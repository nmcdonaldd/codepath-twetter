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
    var userID: String?
    var profileURL: URL?
    var profileBackdropURL: URL?
    var cachedProfileImage: UIImage?
    var followersCount: Int? {
        didSet {
            let nf: NumberFormatter = NumberFormatter()
            nf.numberStyle = .decimal
            self.formattedFollowersCount = nf.string(from: NSNumber(value: self.followersCount!))
        }
    }
    var followingCount: Int? {
        didSet {
            let nf: NumberFormatter = NumberFormatter()
            nf.numberStyle = .decimal
            self.formattedFollowingCount = nf.string(from: NSNumber(value: self.followingCount!))
        }
    }
    var formattedFollowersCount: String?
    var formattedFollowingCount: String?
    var isCurrentUserFollowing: Bool?
    var numberOfTweets: Int?
    
    var originalDicitonary: NSDictionary?
    
    init(userDictionary: NSDictionary) {
        self.originalDicitonary = userDictionary
        self.name = userDictionary["name"] as? String
        self.username = userDictionary["screen_name"] as? String
        self.tagline = userDictionary["description"] as? String
        
        if let id: String = userDictionary["id_str"] as? String {
            self.userID = id
        }
        
        userProfileURLLabel: if let profileImgURLString: String = userDictionary["profile_image_url_https"] as? String {
            guard let profileImgURL: URL = URL(string: profileImgURLString) else {
                break userProfileURLLabel
            }
            self.profileURL = profileImgURL
        }
        
        backdropURLLabel: if let backdropURLString: String = userDictionary["profile_banner_url"] as? String {
            guard let backdropURL: URL = URL(string: backdropURLString) else {
                break backdropURLLabel
            }
            self.profileBackdropURL = backdropURL
        }
        
        self.followersCount = userDictionary["followers_count"] as? Int
        self.isCurrentUserFollowing = userDictionary["following"] as? Bool
        self.numberOfTweets = userDictionary["statuses_count"] as? Int
        self.followingCount = userDictionary["friends_count"] as? Int
        
        let nf: NumberFormatter = NumberFormatter()
        nf.numberStyle = .decimal
        self.formattedFollowingCount = nf.string(from: NSNumber(value: self.followingCount!))
        self.formattedFollowersCount = nf.string(from: NSNumber(value: self.followersCount!))
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
