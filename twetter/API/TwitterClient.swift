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
    static private let twetterFollowPrefixEndpoint: String = "1.1/friendships/"
    
    private var loginSuccess: (()->())?
    private var loginFailure: ((Error?)->())?
    
    static let sharedInstance: TwitterClient = TwitterClient(baseURL: URL(string: TwitterClient.twitterAPIURL)!, consumerKey: TwitterClient.twitterAppConsumerKey, consumerSecret: TwitterClient.twitterAppConsumerSecret)
    
    func currentAccount(success: @escaping (User)->(), failure: @escaping (Error)->()) {
        self.get(TwitterClient.verifyCredentialsEndpoint, parameters: nil, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            let userDictionary: NSDictionary = response as! NSDictionary
            let user: User = User(userDictionary: userDictionary)
            
            success(user)
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            failure(error)
        })
    }
    
    func homeTimeline(startingAtTweetID tweetIDToStart: String?, success: @escaping ([Tweet])->(), failure: @escaping (Error)->()) {
        
        var paramDict: [String: String] = [String: String]()
        paramDict.updateValue(tweetsToLoadCount, forKey: "count")
        if let sinceTweetID: String = tweetIDToStart {
            paramDict.updateValue(sinceTweetID, forKey: "max_id")
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
    
    func getUsersTweets(_ user: User, startingAtTweetID tweetIDToStart: String?, success: @escaping ([Tweet])->(), failure: @escaping (Error?)->()) {
        guard let userID: String = user.userID else {
            return
        }
        
        var paramDictionary: [String: String] = [String: String]()
        paramDictionary.updateValue(userID, forKey: "user_id")
        
        if let tweetID: String = tweetIDToStart {
            paramDictionary.updateValue(tweetID, forKey: "max_id")
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
    
    // Returns a User object from the passed-in userID string.s
    func getUserWithID(_ userID: String, success: @escaping (User)->(), failure: @escaping (Error?)->()) {
        
        var paramDict: [String: String] = [String: String]()
        paramDict.updateValue(userID, forKey: "user_id")
        
        self.get(TwitterClient.getUserEndpoint, parameters: paramDict, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            
            let userDict: NSDictionary = response as! NSDictionary
            let user: User = User(userDictionary: userDict)
            
            success(user)
            
        }) { (task: URLSessionDataTask?, error: Error) in
            failure(error)
        }
    }
    
    func login(success: @escaping ()->(), failure: @escaping (Error?)->()) {
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
                User.currentUser = user
                self.loginSuccess?()
            }, failure: { (error: Error) in
                self.loginFailure?(error)
            })
        }) { (error: Error?) in
            print ("Got an error: \(error?.localizedDescription)")
            self.loginFailure?(error)
        }
    }
    
    func toggleFollowingUser(withID userID: String, isAlreadyFollowing alreadyFollowing: Bool, success: @escaping ()->(), failure: @escaping (Error?)->()) {
        var postString = TwitterClient.twetterFollowPrefixEndpoint
        postString += alreadyFollowing ? "destroy" : "create"
        postString += ".json"
        var paramDict: [String: String] = [String: String]()
        paramDict.updateValue(userID, forKey: "user_id")
        
        self.post(postString, parameters: paramDict, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            success()
        }) { (task: URLSessionDataTask?, error: Error?) in
            failure(error)
        }
    }
    
    func tweetWithText(_ text: String, inReplyToTweet: Tweet?, success: @escaping (Tweet)->(), failure: @escaping (Error?)->()) {
        
        var paramDict: [String: String] = [String: String]()
        paramDict.updateValue(text, forKey: "status")
        
        if let tweet: Tweet = inReplyToTweet {
            let replyTweetID: String = tweet.tweetID!
            paramDict.updateValue(replyTweetID, forKey: "in_reply_to_status_id")
        }
        
        self.post(TwitterClient.submitTweetEndpoint, parameters: paramDict, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            
            // Find something to do here!
            let tweetResponse: NSDictionary = response as! NSDictionary
            let tweet: Tweet = Tweet(tweetDictionary: tweetResponse)
            success(tweet)
        }) { (task: URLSessionDataTask?, error: Error) in
            failure(error)
        }
    }
    
    func retweet(tweet: Tweet, success: @escaping ()->(),  failure: @escaping (Error?)->()) {
        
        guard let tweetID: String = tweet.tweetID else {
            // Somehow a tweet with no ID is requesting to be retweeted by the user. Good job user, you broke it.
            // TODO: - make this an error, not just print error.
            print("Error!")
            return
        }
        
        let action: String = tweet.isRetweeted ? "unretweet" : "retweet"
        self.post("1.1/statuses/\(action)/\(tweetID).json", parameters: nil, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            success()
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            failure(error)
        })
    }
    
    func favorite(tweet: Tweet, success: @escaping ()->(), failure: @escaping (Error?)->()) {
        
        guard let tweetID: String = tweet.tweetID else {
            // Somehow a tweet with no ID is requesting to be retweeted by the user. Good job user, you broke it.
            print("Error!")
            return
        }
        let action: String = tweet.isFavorited ? "destroy" : "create"
        var paramDict: [String: String] = [String: String]()
        paramDict.updateValue(tweetID, forKey: "id")
        self.post("1.1/favorites/\(action).json", parameters: paramDict, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            success()
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            failure(error)
        })
    }
}
