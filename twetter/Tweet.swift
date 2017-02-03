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
    var retweetCount: Int = 0
    var favoriteCount: Int = 0
    var retweeted: Bool = false
    var identifier: Int = 0
    
    var tweetAuthor: User?
    var tweetMediaEntities: TweetEntities?
    
    init(tweetDictionary: NSDictionary) {
        self.text = tweetDictionary["text"] as? String
        self.retweetCount = (tweetDictionary["retweet_count"] as? Int) ?? 0
        self.favoriteCount = (tweetDictionary["favourite_count"] as? Int) ?? 0
        
        let timeStampString: String? = tweetDictionary["created_at"] as? String
        
        if let timeStampString = timeStampString {
            let dateFormatter: DateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
            self.timeStamp = dateFormatter.date(from: timeStampString)
        }
        
        let userDictonary = tweetDictionary["user"] as! NSDictionary
        self.tweetAuthor = User(userDictionary: userDictonary)
        
        // TODO: - Grab the pictures "entities"
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
