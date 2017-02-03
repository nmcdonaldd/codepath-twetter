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
    
    var loginSuccess: (() -> ())?
    var loginFailure: ((Error?) -> ())?
    
    static let sharedInstance: TwitterClient = TwitterClient(baseURL: URL(string: "https://api.twitter.com")!, consumerKey: "70bX4mBjct3kGzW4N50sZ1U8J", consumerSecret: "grP8gG84NNfu38tn9vmVvE7tlLwqtaY8elJJ4ma5NgnDQdGN98")
    
    func currentAccount(success: @escaping (User) -> (), failure: @escaping (Error) -> ()) {
        self.get("1.1/account/verify_credentials.json", parameters: nil, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            let userDictionary: NSDictionary = response as! NSDictionary
            let user: User = User(userDictionary: userDictionary)
            
            success(user)
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            failure(error)
        })
    }
    
    func homeTimeline(success: @escaping ([Tweet]) -> (), failure: @escaping (Error) -> ()) {
        self.get("1.1/statuses/home_timeline.json", parameters: nil, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            
            let tweetsDictionaries: [NSDictionary] = response as! [NSDictionary]
//            for tweet in tweetsDictionaries {
//                print("Tweet: \(tweet)\n")
//            }
            let tweets: [Tweet] = Tweet.tweetsFromArray(tweetsDictionaries: tweetsDictionaries)
            
            success(tweets)
            
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            failure(error)
        })
    }
    
    func login(success: @escaping ()->(), failure: @escaping (Error?) -> ()) {
        self.loginSuccess = success
        self.loginFailure = failure
        self.deauthorize()
        self.fetchRequestToken(withPath: "oauth/request_token", method: "GET", callbackURL: URL(string: "twetter://oauth"), scope: nil, success: { (requestToken: BDBOAuth1Credential?) in
            let url: URL = URL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(requestToken!.token!)")!
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
        self.fetchAccessToken(withPath: "oauth/access_token", method: "POST", requestToken: requestToken, success: { (accessToken: BDBOAuth1Credential?) in
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
}
