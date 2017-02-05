//
//  Tweet.swift
//  twetter
//
//  Created by Nick McDonald on 1/29/17.
//  Copyright © 2017 Nick McDonald. All rights reserved.
//

import UIKit

class Tweet: NSObject {
    
    var text: String?
    var timeStamp: Date?
    var retweetCount: Int! {
        didSet {
            self.formattedRetweetNumString = Tweet.formatNumberToString(num: self.retweetCount!)
        }
    }
    var favoriteCount: Int! {
        didSet {
            self.formattedFavoriteNumString = Tweet.formatNumberToString(num: self.favoriteCount!)
        }
    }
    var isRetweeted: Bool = false
    var isFavorited: Bool = false
    
    var identifier: Int = 0
    var id: String?
    var formattedRetweetNumString: String?
    var formattedFavoriteNumString: String?
    
    var tweetAuthor: User?
    var tweetMediaEntities: TweetEntities?
    
    init(tweetDictionary: NSDictionary) {
        self.text = tweetDictionary["text"] as? String
        self.retweetCount = (tweetDictionary["retweet_count"] as! Int)
        self.favoriteCount = (tweetDictionary["favorite_count"] as! Int)
        self.formattedRetweetNumString = Tweet.formatNumberToString(num: self.retweetCount)
        self.formattedFavoriteNumString = Tweet.formatNumberToString(num: self.favoriteCount)
        
        let timeStampString: String? = tweetDictionary["created_at"] as? String
        
        if let timeStampString = timeStampString {
            let dateFormatter: DateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
            self.timeStamp = dateFormatter.date(from: timeStampString)
        }
        
        let tweetID: String? = tweetDictionary["id_str"] as? String
        
        if let tweetIdentifier: String = tweetID {
            self.id = tweetIdentifier
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
    
    private class func formatNumberToString(num: Int) -> String? {
        let nf: NumberFormatter = NumberFormatter()
        return nf.string(from: NSNumber(value: num))
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
