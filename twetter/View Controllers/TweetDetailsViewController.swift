//
//  TweetDetailsViewController.swift
//  twetter
//
//  Created by Nick McDonald on 2/10/17.
//  Copyright © 2017 Nick McDonald. All rights reserved.
//

import UIKit
import SVProgressHUD

protocol TweetDetailsViewControllerDelegate: class {
    func tweetDetailsViewControllerDidUpdateRTOrFavoriteValue()
}

class TweetDetailsViewController: BaseTwetterViewController {
    
    // String constants for names
    private static let retweetsPlural: String = "RETWEETS"
    private static let retweetSingular: String = "RETWEET"
    private static let favoritesPlural: String = "FAVORITES"
    private static let favoriteSingular: String = "FAVORITE"
    private static let retweetGreyImageIdentifier: String = "Retweet grey"
    private static let retweetGreenImageIdentifier: String = "Retweet green"
    private static let favoriteGreyIdentifier: String = "Heart grey"
    private static let favoriteRedIdentifier: String = "Heart red"
    
    @IBOutlet weak var tweetAuthorImageView: UIImageView!
    @IBOutlet weak var tweetAuthorNameLabel: UILabel!
    @IBOutlet weak var tweetAuthorUsernameLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    @IBOutlet weak var tweetCreatedAtLabel: UILabel!
    @IBOutlet weak var tweetAuthorInfoView: UIView!
    
    @IBOutlet weak var retweetCountLabel: UILabel!
    @IBOutlet weak var retweetsTextLabel: UILabel!
    @IBOutlet weak var favoriteCountLabel: UILabel!
    @IBOutlet weak var favoriteTextLabel: UILabel!
    
    @IBOutlet weak var retweetImageView: UIImageView!
    @IBOutlet weak var favoriteImageView: UIImageView!
    @IBOutlet weak var replyImageView: UIImageView!
    
    @IBOutlet weak var tweetMediaImageView: UIImageView!
    @IBOutlet weak var tweetMediaImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var tweetContentView: UIView!
    var tweetData: Tweet!
    
    weak var delegate: TweetDetailsViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.fillViewsWithData()
        
        let retweetTapRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(TweetDetailsViewController.userTappedRetweet))
        let favoriteTapRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(TweetDetailsViewController.userTappedFavorite))
        let replyTapRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(TweetDetailsViewController.userTappedReply))
        let profileTapRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(TweetDetailsViewController.userTappedProfileImage))
        
        self.retweetImageView.addGestureRecognizer(retweetTapRecognizer)
        self.retweetImageView.isUserInteractionEnabled = true
        self.favoriteImageView.addGestureRecognizer(favoriteTapRecognizer)
        self.favoriteImageView.isUserInteractionEnabled = true
        self.replyImageView.addGestureRecognizer(replyTapRecognizer)
        self.replyImageView.isUserInteractionEnabled = true
        self.tweetAuthorImageView.addGestureRecognizer(profileTapRecognizer)
        self.tweetAuthorImageView.isUserInteractionEnabled = true
        
        self.scrollView.contentSize = CGSize(width: self.view.frame.width, height: self.tweetContentView.frame.height)
        
        let backBarButtonItem: UIBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = backBarButtonItem
    }
    
    func userTappedProfileImage() {
        guard let user: User = tweetData.tweetAuthor else {
            return
        }
        let navVC: TwetterNavigationController = self.navigationController as! TwetterNavigationController
        navVC.pushProfileViewControllerOfUser(user)
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
        
        tweetMediaLabel:
            if let tweetMediaInfo: TweetEntities = self.tweetData.getTweetEntities() {
                // Need to grab the url for the tweet media.
                // For now, let's just grab the first TweetMedia
                guard let mediaInfo: TweetMedia = tweetMediaInfo.mediaInfo?.first else {
                    break tweetMediaLabel
                }
                
                guard let mediaSize: CGSize = mediaInfo.mediaSize() else {
                    break tweetMediaLabel
                }
                
                guard let mediaURL: URL = mediaInfo.URLOfMedia() else {
                    break tweetMediaLabel
                }
                
                let mediaHeight: CGFloat = mediaSize.height
                let mediaWidth: CGFloat = mediaSize.width
                
                self.tweetMediaImageViewHeightConstraint.constant = (mediaHeight * tweetMediaImageView.frame.size.width) / mediaWidth
                self.tweetMediaImageView.setImageWith(mediaURL)
            }
        
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
            self.retweetsTextLabel.text = retweetsCount == 1 ? TweetDetailsViewController.retweetSingular : TweetDetailsViewController.retweetsPlural
        }
        
        if let favoritesCount: Int = tweetData.favoriteCount {
            self.favoriteCountLabel.text = tweetData.formattedFavoriteNumString
            self.favoriteTextLabel.text = favoritesCount == 1 ? TweetDetailsViewController.favoriteSingular : TweetDetailsViewController.favoritesPlural
        }
        
        // Setup the buttons.
        let selectedRetweetAssetName: String = tweetData.isRetweeted ? TweetDetailsViewController.retweetGreenImageIdentifier : TweetDetailsViewController.retweetGreyImageIdentifier
        let selectedFavoriteAssetName: String = tweetData.isFavorited ? TweetDetailsViewController.favoriteRedIdentifier : TweetDetailsViewController.favoriteGreyIdentifier
        self.retweetImageView.image = UIImage(imageLiteralResourceName: selectedRetweetAssetName)
        self.favoriteImageView.image = UIImage(imageLiteralResourceName: selectedFavoriteAssetName)
    }
    
    func userTappedRetweet() {
        self.tweetData.toggleRetweet(success: {
           self.retweetCountLabel.text = self.tweetData.formattedRetweetNumString
            let retweetNoun: String = self.tweetData.retweetCount == 1 ? TweetDetailsViewController.retweetSingular : TweetDetailsViewController.retweetsPlural
            self.retweetsTextLabel.text = retweetNoun
            let retweetAssetName: String = self.tweetData.isRetweeted ? TweetDetailsViewController.retweetGreenImageIdentifier : TweetDetailsViewController.retweetGreyImageIdentifier
            self.retweetImageView.image = UIImage(imageLiteralResourceName: retweetAssetName)
            self.delegate?.tweetDetailsViewControllerDidUpdateRTOrFavoriteValue()
        }) { (error: Error?) in
            SVProgressHUD.showError(withStatus: error?.localizedDescription)
        }
    }
    
    func userTappedFavorite() {
        self.tweetData.toggleFavorite(success: {
            self.favoriteCountLabel.text = self.tweetData.formattedFavoriteNumString
            let favoriteNoun: String = self.tweetData.favoriteCount == 1 ? TweetDetailsViewController.favoriteSingular: TweetDetailsViewController.favoritesPlural
            self.favoriteTextLabel.text = favoriteNoun
            let favoriteAssetName: String = self.tweetData.isFavorited ? TweetDetailsViewController.favoriteRedIdentifier : TweetDetailsViewController.favoriteGreyIdentifier
            self.favoriteImageView.image = UIImage(imageLiteralResourceName: favoriteAssetName)
            self.delegate?.tweetDetailsViewControllerDidUpdateRTOrFavoriteValue()
        }) { (error: Error?) in
            self.favoriteImageView.image = UIImage(imageLiteralResourceName: TweetDetailsViewController.favoriteGreyIdentifier)
            SVProgressHUD.showError(withStatus: error?.localizedDescription)
        }
    }
    
    func userTappedReply() {
        self.composeTweetButtonTapped()
    }
    
    override func composeTweetButtonTapped() {
        self.presentComposeTweetToUser(nil, orInReplyTo: self.tweetData, withSender: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
