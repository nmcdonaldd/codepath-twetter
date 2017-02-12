//
//  TweetDetailsViewController.swift
//  twetter
//
//  Created by Nick McDonald on 2/10/17.
//  Copyright © 2017 Nick McDonald. All rights reserved.
//

import UIKit

class TweetDetailsViewController: BaseTwetterViewController {
    
    @IBOutlet weak var tweetAuthorImageView: UIImageView!
    @IBOutlet weak var tweetAuthorNameLabel: UILabel!
    @IBOutlet weak var tweetAuthorUsernameLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    @IBOutlet weak var tweetCreatedAtLabel: UILabel!
    
    @IBOutlet weak var retweetCountLabel: UILabel!
    @IBOutlet weak var retweetsTextLabel: UILabel!
    @IBOutlet weak var favoriteCountLabel: UILabel!
    @IBOutlet weak var favoriteTextLabel: UILabel!
    
    var tweetData: Tweet!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.fillViewsWithData()
    }
    
    private func fillViewsWithData() {
        
        guard let tweetAuthor = self.tweetData.tweetAuthor else {
            // Show an error.
            return
        }
        
        // Set the tweet author profile imageView.
        if let tweetAuthorImage: UIImage = tweetAuthor.cachedProfileImage {
            self.tweetAuthorImageView.image = tweetAuthorImage
        } else {
            if let authorProfileImageURL: URL = tweetAuthor.profileURL {
                let request: URLRequest = URLRequest(url: authorProfileImageURL, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
                self.tweetAuthorImageView.setImageWith(request, placeholderImage: nil, success: { (request: URLRequest, response: HTTPURLResponse?, image: UIImage) in
                    
                    // Successful response from the network.
                    tweetAuthor.setCachedProfileImage(image: image)
                    self.tweetAuthorImageView.image = image
                    
                }, failure: { (request: URLRequest, response: HTTPURLResponse?, error: Error) in
                    // Error.
                })
                self.tweetAuthorImageView.setImageWith(authorProfileImageURL)
            }
        }
        
        self.tweetAuthorImageView.layer.cornerRadius = 4.0
        self.tweetAuthorImageView.clipsToBounds = true
        
        // Set the tweet text.
        if let tweetText: String = self.tweetData.text {
            self.tweetTextLabel.text = tweetText
        }
        
        // Set the author names/usernames.
        if let authorName: String = tweetAuthor.name {
            self.tweetAuthorNameLabel.text = authorName
        }
        
        if let authorUsername: String = tweetAuthor.username {
            self.tweetAuthorUsernameLabel.text = "@\(authorUsername)"
        }
        
        // Set up the tweet relative time.
        if let relativeTime: String = tweetData.relativeTime {
            self.tweetCreatedAtLabel.text = relativeTime
        }
        
        // Set up the favorites/retweets count view.
        if let retweetsCount: Int = tweetData.retweetCount {
            self.retweetCountLabel.text = tweetData.formattedRetweetNumString
            self.retweetsTextLabel.text = retweetsCount == 1 ? "RETWEET" : "RETWEETS"
        }
        
        if let favoritesCount: Int = tweetData.favoriteCount {
            self.favoriteCountLabel.text = tweetData.formattedFavoriteNumString
            self.favoriteTextLabel.text = favoritesCount == 1 ? "FAVORITE" : "FAVORITES"
        }
    }
    
    override func composeTweetButtonTapped() {
        self.presentComposeTweetInReplyToPossibleTweet(self.tweetData)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
