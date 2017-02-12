//
//  TweetDetailsViewController.swift
//  twetter
//
//  Created by Nick McDonald on 2/10/17.
//  Copyright © 2017 Nick McDonald. All rights reserved.
//

import UIKit
import SVProgressHUD

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
    
    @IBOutlet weak var retweetImageView: UIImageView!
    @IBOutlet weak var favoriteImageView: UIImageView!
    @IBOutlet weak var replyImageView: UIImageView!
    
    var tweetData: Tweet!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.fillViewsWithData()
        
        let retweetTapRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(TweetDetailsViewController.userTappedRetweet))
        let favoriteTapRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(TweetDetailsViewController.userTappedFavorite))
        let replyTapRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(TweetDetailsViewController.userTappedReply))
        
        self.retweetImageView.addGestureRecognizer(retweetTapRecognizer)
        self.retweetImageView.isUserInteractionEnabled = true
        self.favoriteImageView.addGestureRecognizer(favoriteTapRecognizer)
        self.favoriteImageView.isUserInteractionEnabled = true
        self.replyImageView.addGestureRecognizer(replyTapRecognizer)
        self.replyImageView.isUserInteractionEnabled = true
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
        
        // Setup the buttons.
        let selectedRetweetAssetName: String = tweetData.isRetweeted ? "Retweet green" : "Retweet grey"
        let selectedFavoriteAssetName: String = tweetData.isFavorited ? "Heart red" : "Heart grey"
        self.retweetImageView.image = UIImage(imageLiteralResourceName: selectedRetweetAssetName)
        self.favoriteImageView.image = UIImage(imageLiteralResourceName: selectedFavoriteAssetName)
    }
    
    func userTappedRetweet() {
        
        // Ask the twitter client to favorite this tweet. Give it the tweet ID.
        let twitterClient: TwitterClient = TwitterClient.sharedInstance
        
        twitterClient.retweet(tweet: self.tweetData, success: { [weak self] (retweetCount: Int) in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.tweetData.retweetCount = retweetCount
            strongSelf.tweetData.isRetweeted = !strongSelf.tweetData.isRetweeted
            strongSelf.retweetCountLabel.text = strongSelf.tweetData.formattedRetweetNumString
            
            let retweetNoun: String = strongSelf.tweetData.retweetCount == 1 ? "RETWEET" : "RETWEETS"
            strongSelf.retweetsTextLabel.text = retweetNoun
            
            let retweetAssetName: String = strongSelf.tweetData.isRetweeted ? "Retweet green" : "Retweet grey"
            strongSelf.retweetImageView.image = UIImage(imageLiteralResourceName: retweetAssetName)
            
        }) { [weak self] (error: Error?) in
            print("Error on retweet request: \(error?.localizedDescription)")
            self?.retweetImageView.image = UIImage(imageLiteralResourceName: "Retweet grey")
            SVProgressHUD.showError(withStatus: error?.localizedDescription)
        }
        
    }
    
    func userTappedFavorite() {
        let twitterClient: TwitterClient = TwitterClient.sharedInstance
        
        twitterClient.favorite(tweet: self.tweetData, success: { [weak self] (favoriteCount: Int) in
            
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.tweetData.favoriteCount = favoriteCount
            strongSelf.tweetData.isFavorited = !strongSelf.tweetData.isFavorited
            strongSelf.favoriteCountLabel.text = strongSelf.tweetData.formattedFavoriteNumString
            
            let favoriteNoun: String = strongSelf.tweetData.favoriteCount == 1 ? "FAVORITE" : "FAVORITES"
            strongSelf.favoriteTextLabel.text = favoriteNoun
            let favoriteAssetName: String = strongSelf.tweetData.isFavorited ? "Heart red" : "Heart grey"
            strongSelf.favoriteImageView.image = UIImage(imageLiteralResourceName: favoriteAssetName)
            
        }) { [weak self] (error: Error?) in
            print("Error on favorite request: \(error?.localizedDescription)")
            self?.favoriteImageView.image = UIImage(imageLiteralResourceName: "Heart grey")
            SVProgressHUD.showError(withStatus: error?.localizedDescription)
        }
    }
    
    func userTappedReply() {
        self.composeTweetButtonTapped()
    }
    
    override func composeTweetButtonTapped() {
        self.presentComposeTweetInReplyToPossibleTweet(self.tweetData)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
