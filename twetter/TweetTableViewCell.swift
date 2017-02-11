//
//  TweetTableViewCell.swift
//  twetter
//
//  Created by Nick McDonald on 2/1/17.
//  Copyright © 2017 Nick McDonald. All rights reserved.
//

import UIKit
import SwiftDate

class TweetTableViewCell: UITableViewCell {

    @IBOutlet weak var tweetTextLabel: UILabel!
    @IBOutlet weak var tweetCreatedAtLabel: UILabel!
    @IBOutlet weak var tweetAuthorUsernameLabel: UILabel!
    @IBOutlet weak var tweetAuthorNameLabel: UILabel!
    @IBOutlet weak var tweetAuthorImageView: UIImageView!
    @IBOutlet weak var tweetFunctionsContainerView: UIView!
    @IBOutlet weak var retweetImageView: UIImageView!
    @IBOutlet weak var favoriteImageView: UIImageView!
    @IBOutlet weak var retweetsLabel: UILabel!
    @IBOutlet weak var favoritesLabel: UILabel!
    
    // This is the data source for this tweet.
    var tweetData: Tweet! {
        didSet {
            
            guard let tweetAuthor: User = self.tweetData.tweetAuthor else {
                return
            }
            
            self.retweetsLabel.text = self.tweetData.formattedRetweetNumString
            self.favoritesLabel.text = self.tweetData.formattedFavoriteNumString
            
            if let text = self.tweetData.text {
                self.tweetTextLabel.text = text
            }
            
            if let tweetCreatedRelativeTime: String = self.tweetData.relativeTime {
                self.tweetCreatedAtLabel.text = tweetCreatedRelativeTime
            }
            
            if let authorUsername = tweetAuthor.username {
                self.tweetAuthorUsernameLabel.text = "@\(authorUsername)"
            }
            
            if let authorName = tweetAuthor.name {
                self.tweetAuthorNameLabel.text = authorName
            }
            
            if let tweetAuthorImage: UIImage = tweetAuthor.cachedProfileImage {
                self.tweetAuthorImageView.image = tweetAuthorImage
            } else {
                if let authorProfileImageURL = tweetAuthor.profileURL {
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
            
            let selectedRTImageAssetName: String = self.tweetData.isRetweeted ? "Retweet green" : "Retweet grey"
            let selectedFavImageAssetName: String = self.tweetData.isFavorited ? "Heart red" : "Heart grey"
            self.retweetImageView.image = UIImage(imageLiteralResourceName: selectedRTImageAssetName)
            self.favoriteImageView.image = UIImage(imageLiteralResourceName: selectedFavImageAssetName)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        self.tweetAuthorImageView.layer.cornerRadius = 4.0
        self.tweetAuthorImageView.clipsToBounds = true
        
        let retweetTapRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(TweetTableViewCell.userTappedRetweet))
        let favoriteTapRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(TweetTableViewCell.userTappedFavorite))
        
        self.retweetImageView.addGestureRecognizer(retweetTapRecognizer)
        self.retweetImageView.isUserInteractionEnabled = true
        self.favoriteImageView.addGestureRecognizer(favoriteTapRecognizer)
        self.favoriteImageView.isUserInteractionEnabled = true
    }
    
    func userTappedRetweet() {
        // NOTE: - The following might not apply to retweet!!
        // TODO: - Check to see if the tweet has already been retweeted. If so, we will get an error.
        //       - At this point, do nothing.
        
        // Ask the twitter client to favorite this tweet. Give it the tweet ID.
        let twitterClient: TwitterClient = TwitterClient.sharedInstance
        self.retweetImageView.image = UIImage(imageLiteralResourceName: "Retweet green")
        
        twitterClient.retweet(tweet: self.tweetData, success: { (retweetCount: Int) in
            self.tweetData.retweetCount = retweetCount
            self.retweetsLabel.text = self.tweetData.formattedRetweetNumString
        }) { (error: Error?) in
            print("Error on retweet request: \(error?.localizedDescription)")
            self.retweetImageView.image = UIImage(imageLiteralResourceName: "Retweet grey")
        }
    }
    
    func userTappedFavorite() {
        // TODO: - Check to see if the tweet has already been favorited. If so, we will get an error.
        //       - At this point, do nothing.
        
        let twitterClient: TwitterClient = TwitterClient.sharedInstance
        self.favoriteImageView.image = UIImage(imageLiteralResourceName: "Heart red")
        
        twitterClient.favorite(tweet: self.tweetData, success: { (favoriteCount: Int) in
            self.tweetData.favoriteCount = favoriteCount
            self.favoritesLabel.text = self.tweetData.formattedFavoriteNumString
        }) { (error: Error?) in
            print("Error on favorite request: \(error?.localizedDescription)")
            self.favoriteImageView.image = UIImage(imageLiteralResourceName: "Heart grey")
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.favoriteImageView.image = UIImage(imageLiteralResourceName: "Heart grey")
        self.retweetImageView.image = UIImage(imageLiteralResourceName: "Retweet grey")
    }

}
