//
//  Tweet.swift
//  twetter
//
//  Created by Nick McDonald on 1/29/17.
//  Copyright © 2017 Nick McDonald. All rights reserved.
//

import UIKit
import SwiftDate

class Tweet: NSObject {
    
    var text: String?
    var timeStamp: Date?
    var relativeTime: String?
    var retweetCount: Int? {
        didSet {
            let nf: NumberFormatter = NumberFormatter()
            nf.numberStyle = .decimal
            self.formattedRetweetNumString = nf.string(from: NSNumber(value: self.retweetCount!))
        }
    }
    var favoriteCount: Int? {
        didSet {
            let nf: NumberFormatter = NumberFormatter()
            nf.numberStyle = .decimal
            self.formattedFavoriteNumString = nf.string(from: NSNumber(value: self.favoriteCount!))
        }
    }
    var isRetweeted: Bool = false
    var isFavorited: Bool = false
    
    var identifier: Int = 0
    var tweetID: String?
    var formattedRetweetNumString: String?
    var formattedFavoriteNumString: String?
    
    var tweetAuthor: User?
    var tweetMediaEntities: TweetEntities?
    
    init(tweetDictionary: NSDictionary) {
        
        // Set up the basic Tweet details.
        self.text = tweetDictionary["text"] as? String
        self.retweetCount = (tweetDictionary["retweet_count"] as! Int)
        self.favoriteCount = (tweetDictionary["favorite_count"] as! Int)
        let timeStampString: String? = tweetDictionary["created_at"] as? String
        
        let nf: NumberFormatter = NumberFormatter()
        nf.numberStyle = .decimal
        self.formattedFavoriteNumString = nf.string(from: NSNumber(value: self.favoriteCount!))
        self.formattedRetweetNumString = nf.string(from: NSNumber(value: self.retweetCount!))
        
        // Set up the time stamp information for the Tweet.
        if let timeStampString = timeStampString {
            let dateFormatter: DateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
            self.timeStamp = dateFormatter.date(from: timeStampString)
            
            let date: DateInRegion = try! DateInRegion(string: (self.timeStamp?.description)!, format: .custom("yyyy-MM-dd HH:mm:ss Z"))
            let (colloquial, _) = try! date.colloquialSinceNow()
            
            self.relativeTime = colloquial
        }
        
        let tweetID: String? = tweetDictionary["id_str"] as? String
        
        if let tweetIdentifier: String = tweetID {
            self.tweetID = tweetIdentifier
        }
        
        self.isFavorited = tweetDictionary["favorited"] as! Bool
        self.isRetweeted = tweetDictionary["retweeted"] as! Bool
        
        let userDictonary = tweetDictionary["user"] as! NSDictionary
        self.tweetAuthor = User(userDictionary: userDictonary)
        
        let tweetEntities: NSDictionary? = tweetDictionary.value(forKeyPath: "entities") as? NSDictionary
        let entityMedia = tweetEntities?.mutableArrayValue(forKey: "media")
        if let media = entityMedia {
            for value in media {
                let entityDictionary = value as! NSDictionary
                self.tweetMediaEntities = TweetEntities(mediaDictionary: entityDictionary)
            }
        }
        
    }
    
    class func tweetsFromArray(tweetsDictionaries: [NSDictionary]) -> [Tweet] {
        var tweets: [Tweet] = [Tweet]()
        
        for dictionary in tweetsDictionaries {
            let tweet: Tweet = Tweet(tweetDictionary: dictionary)
            
            tweets.append(tweet)
        }
        
        return tweets
    }

}
