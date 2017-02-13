//
//  TwitterClient.swift
//  twetter
//
//  Created by Nick McDonald on 1/30/17.
//  Copyright © 2017 Nick McDonald. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

class TwitterClient: BDBOAuth1SessionManager {
    
    // Constants
    static private let twitterAPIURL: String = "https://api.twitter.com"
    static private let twitterAppConsumerKey: String = "70bX4mBjct3kGzW4N50sZ1U8J"
    static private let twitterAppConsumerSecret: String = "grP8gG84NNfu38tn9vmVvE7tlLwqtaY8elJJ4ma5NgnDQdGN98"
    static private let verifyCredentialsEndpoint: String = "1.1/account/verify_credentials.json"
    static private let homeTimelineEndpoint: String = "1.1/statuses/home_timeline.json"
    static private let submitTweetEndpoint: String = "1.1/statuses/update.json"
    static private let getUserTweetsEndpoint: String = "1.1/statuses/user_timeline.json"
    static private let getUserEndpoint: String = "1.1/users/show.json"
    static private let OAuthRequestPath: String = "oauth/request_token"
    static private let OAuthAccessPath: String = "oauth/access_token"
    static private let requestTokenPath: String = "https://api.twitter.com/oauth/authorize?oauth_token="
    static private let twetterCallBackURL: String = "twetter://oauth"
    
    private var loginSuccess: (() -> ())?
    private var loginFailure: ((Error?) -> ())?
    
    static let sharedInstance: TwitterClient = TwitterClient(baseURL: URL(string: TwitterClient.twitterAPIURL)!, consumerKey: TwitterClient.twitterAppConsumerKey, consumerSecret: TwitterClient.twitterAppConsumerSecret)
    
    func currentAccount(success: @escaping (User) -> (), failure: @escaping (Error) -> ()) {
        self.get(TwitterClient.verifyCredentialsEndpoint, parameters: nil, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            let userDictionary: NSDictionary = response as! NSDictionary
            let user: User = User(userDictionary: userDictionary)
            
            success(user)
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            failure(error)
        })
    }
    
    func homeTimeline(startingAtTweetID tweetIDToStart: String?, success: @escaping ([Tweet]) -> (), failure: @escaping (Error) -> ()) {
        
        var paramDict: [String: String] = [String: String]()
        paramDict.updateValue(tweetsToLoadCount, forKey: "count")
        if let sinceTweetID: String = tweetIDToStart {
            paramDict.updateValue(sinceTweetID, forKey: "since_id")
        }
        
        self.get(TwitterClient.homeTimelineEndpoint, parameters: paramDict, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            
            let tweetsDictionaries: [NSDictionary] = response as! [NSDictionary]
            let tweets: [Tweet] = Tweet.tweetsFromArray(tweetsDictionaries: tweetsDictionaries)
            
            success(tweets)
            
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            failure(error)
            print(error)
        })
    }
    
    func getUsersTweets(_ user: User, startingAtTweetID tweetIDToStart: String?, success: @escaping ([Tweet]) -> (), failure: @escaping (Error?) -> ()) {
        guard let userID: String = user.userID else {
            return
        }
        
        var paramDictionary: [String: String] = [String: String]()
        paramDictionary.updateValue(userID, forKey: "user_id")
        
        if let tweetID: String = tweetIDToStart {
            paramDictionary.updateValue(tweetID, forKey: "since_id")
        }
        
        self.get(TwitterClient.getUserTweetsEndpoint, parameters: paramDictionary, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            // Code
            let tweetsResponse: [NSDictionary] = (response as? [NSDictionary])!
            
            let tweets: [Tweet] = Tweet.tweetsFromArray(tweetsDictionaries: tweetsResponse)
            success(tweets)
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            // Error
            failure(error)
        })
        
    }
    
    func getUserWithID(_ userID: String, success: @escaping (User)->(), failure: @escaping (Error?) -> ()) {
        self.get(TwitterClient.getUserEndpoint, parameters: ["user_id": userID], progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            
            let userDict: NSDictionary = response as! NSDictionary
            let user: User = User(userDictionary: userDict)
            
            success(user)
            
        }) { (task: URLSessionDataTask?, error: Error) in
            failure(error)
        }
    }
    
    func login(success: @escaping ()->(), failure: @escaping (Error?) -> ()) {
        self.loginSuccess = success
        self.loginFailure = failure
        self.deauthorize()
        self.fetchRequestToken(withPath: TwitterClient.OAuthRequestPath, method: "GET", callbackURL: URL(string: TwitterClient.twetterCallBackURL), scope: nil, success: { (requestToken: BDBOAuth1Credential?) in
            let url: URL = URL(string: TwitterClient.requestTokenPath + requestToken!.token!)!
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            
        }) { (error: Error?) in
            self.loginFailure?(error)
        }
    }
    
    func logout() {
        User.currentUser = nil
        self.deauthorize()
        
        NotificationCenter.default.post(name: UserNotificationCenterOps.userDidLogout.notification, object: nil)
    }
    
    func handleOpenURL(withURL url: URL) {
        
        let requestToken: BDBOAuth1Credential = BDBOAuth1Credential(queryString: url.query)
        self.fetchAccessToken(withPath: TwitterClient.OAuthAccessPath, method: "POST", requestToken: requestToken, success: { (accessToken: BDBOAuth1Credential?) in
            self.currentAccount(success: { (user: User) in
                self.loginSuccess?()
                User.currentUser = user
            }, failure: { (error: Error) in
                self.loginFailure?(error)
            })
            
            self.loginSuccess?()
            
        }) { (error: Error?) in
            print ("Got an error: \(error?.localizedDescription)")
            self.loginFailure?(error)
        }
    }
    
    func tweetWithText(_ text: String, inReplyToTweet: Tweet?, success: @escaping ()->(), failure: @escaping (Error?) -> ()) {
        var postString: String = TwitterClient.submitTweetEndpoint + "?status="
        let encodedString: String = text.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed)!
        print(encodedString)
        postString = postString + encodedString
        
        if let tweet: Tweet = inReplyToTweet {
            let replyTweetID: String = tweet.tweetID!
            postString = postString + "&in_reply_to_status_id=\(replyTweetID)"
        }
        
        self.post(postString, parameters: nil, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            // Code
            // Find something to do here!
            success()
        }) { (task: URLSessionDataTask?, error: Error) in
            // Code
            failure(error)
        }
    }
    
    func retweet(tweet: Tweet, success: @escaping (Int)->(),  failure: @escaping (Error?) -> ()) {
        
        if let tweetID: String = tweet.tweetID {
            let action: String = tweet.isRetweeted ? "unretweet" : "retweet"
            self.post("1.1/statuses/\(action)/\(tweetID).json", parameters: nil, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
                
                let retweetResponseDictionary: NSDictionary = response as! NSDictionary
                let numOfRetweets: Int = retweetResponseDictionary.value(forKeyPath: "retweet_count") as! Int
                success(numOfRetweets)
                
            }, failure: { (task: URLSessionDataTask?, error: Error) in
                failure(error)
            })
        } else {
            // Somehow a tweet with no ID is requesting to be retweeted by the user. Good job user, you broke it.
            print("Error!")
        }
    }
    
    func favorite(tweet: Tweet, success: @escaping (Int) -> (), failure: @escaping (Error?) -> ()) {
        
        if let tweetID: String = tweet.tweetID {
            let action: String = tweet.isFavorited ? "destroy" : "create"
            self.post("1.1/favorites/\(action).json", parameters: ["id": tweetID], progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
                
                let retweetResponseDictionary: NSDictionary = response as! NSDictionary
                let numOfFavorites: Int = retweetResponseDictionary["favorite_count"] as! Int
                success(numOfFavorites)
                
            }, failure: { (task: URLSessionDataTask?, error: Error) in
                failure(error)
            })
        } else {
            // Somehow a tweet with no ID is requesting to be retweeted by the user. Good job user, you broke it.
            print("Error!")
        }

    }
}
