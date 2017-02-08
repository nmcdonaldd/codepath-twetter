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
    @IBOutlet weak var contentImageView: UIImageView!
    @IBOutlet weak var contentImageContainerView: UIView!
    
    @IBOutlet weak var tweetFunctionsContainerView: UIView!
    @IBOutlet weak var retweetImageView: UIImageView!
    @IBOutlet weak var favoriteImageView: UIImageView!
    @IBOutlet weak var retweetsLabel: UILabel!
    @IBOutlet weak var favoritesLabel: UILabel!
    
    var cellRow: IndexPath?
    
    weak var delegate: TweetTableViewCellDelegate?
    
    // This is the data source for this tweet.
    var tweetData: Tweet! {
        didSet {
            
            self.retweetsLabel.text = self.tweetData.formattedRetweetNumString
            self.favoritesLabel.text = self.tweetData.formattedFavoriteNumString
            
            if var text = self.tweetData.text {
                
                if let beginningIndex = self.tweetData.tweetMediaEntities?.mediaBeginIndex {
                    let endingIndex = (self.tweetData.tweetMediaEntities?.mediaEndIndex)!
                    self.contentImageContainerView.isHidden = false
                    
//                    let start = text.index(text.startIndex, offsetBy: beginningIndex)
//                    let end = text.index(text.startIndex, offsetBy: endingIndex-1)
//                    let removeRange: Range<String.Index> = Range(uncheckedBounds: (lower: start, upper: end))
//                    text.removeSubrange(removeRange)
                    
                    // TODO: - change this
                    
                    let request: URLRequest = URLRequest(url: (self.tweetData.tweetMediaEntities?.secureMediaURL)!, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
                    self.contentImageView.setImageWith(request, placeholderImage: nil, success: { [weak self] (request: URLRequest, response: HTTPURLResponse?, image: UIImage) in
                        
                        guard let strongSelf = self else {
                            return
                        }
                        strongSelf.contentImageView.image = image
                        strongSelf.setNeedsLayout()
                        strongSelf.layoutIfNeeded()
                        strongSelf.delegate?.tweetTableViewCell(strongSelf, didFinishLoadingContentWithIndexPath: strongSelf.cellRow!)
                    }, failure: { (request: URLRequest, response: HTTPURLResponse?, error: Error) in
                        //
                    })
                }
                
                
                let attributedName: NSMutableAttributedString = NSMutableAttributedString(string: text)
                let attributedParagraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
                attributedParagraphStyle.lineSpacing = 3.0
                
                let range: NSRange = NSMakeRange(0, text.characters.count)
                attributedName.addAttributes([NSParagraphStyleAttributeName: attributedParagraphStyle], range: range)
                self.tweetTextLabel.attributedText = attributedName
            }
            
            if let createdAt: String = self.tweetData.timeStamp?.description {
                let date: DateInRegion = try! DateInRegion(string: createdAt, format: .custom("yyyy-MM-dd HH:mm:ss Z"))
                let (colloquial, _) = try! date.colloquialSinceNow()
                
                self.tweetCreatedAtLabel.text = colloquial
            }
            
            if let tweetAuthor = self.tweetData.tweetAuthor {
                if let authorUsername = tweetAuthor.username {
                    self.tweetAuthorUsernameLabel.text = "@\(authorUsername)"
                }
                
                if let authorName = tweetAuthor.name {
                    self.tweetAuthorNameLabel.text = authorName
                }
                
                if let authorProfileImageURL = tweetAuthor.profileURL {
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
        self.contentImageContainerView.layer.cornerRadius = 4.0
        self.contentImageContainerView.clipsToBounds = true
        
        let retweetTapRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(TweetTableViewCell.userTappedRetweet))
        let favoriteTapRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(TweetTableViewCell.userTappedFavorite))
        
        self.retweetImageView.addGestureRecognizer(retweetTapRecognizer)
        self.retweetImageView.isUserInteractionEnabled = true
        self.favoriteImageView.addGestureRecognizer(favoriteTapRecognizer)
        self.favoriteImageView.isUserInteractionEnabled = true
    }
    
    func userTappedRetweet() {
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
        self.contentImageContainerView.isHidden = true
        self.contentImageView.image = nil
        self.favoriteImageView.image = UIImage(imageLiteralResourceName: "Heart grey")
        self.retweetImageView.image = UIImage(imageLiteralResourceName: "Retweet grey")
    }

}

protocol TweetTableViewCellDelegate: class {
    func tweetTableViewCell(_ cell: TweetTableViewCell, didFinishLoadingContentWithIndexPath indexPath: IndexPath)
}
