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
    
    // This is the data source for this tweet.
    var tweetData: Tweet! {
        didSet {
            
            if var text = self.tweetData.text {
                
                if let beginningIndex = self.tweetData.tweetMediaEntities?.mediaBeginIndex {
                    let endingIndex = (self.tweetData.tweetMediaEntities?.mediaEndIndex)!
                    self.contentImageView.isHidden = false
                    self.contentImageContainerView.isHidden = false
                    
                    // TODO: - Fix the following so that it allows optionals! Not all tweets have photo media info to remove!
                    let start = text.index(text.startIndex, offsetBy: beginningIndex)
                    let end = text.index(text.startIndex, offsetBy: endingIndex)
                    let removeRange: Range<String.Index> = Range(uncheckedBounds: (lower: start, upper: end))
                    text.removeSubrange(removeRange)
                    
                    print("URL: \((self.tweetData.tweetMediaEntities?.secureMediaURL)!)")
                    self.contentImageView.setImageWith((self.tweetData.tweetMediaEntities?.secureMediaURL)!)
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
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.tweetAuthorImageView.layer.cornerRadius = 5.0
        self.tweetAuthorImageView.clipsToBounds = true
        self.contentImageContainerView.layer.cornerRadius = 4.0
        self.contentImageContainerView.clipsToBounds = true
        self.contentImageContainerView.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
