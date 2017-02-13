//
//  TwitterProfileViewController.swift
//  twetter
//
//  Created by Nick McDonald on 2/12/17.
//  Copyright © 2017 Nick McDonald. All rights reserved.
//

import UIKit
import SVProgressHUD

let offset_HeaderStop:CGFloat = 40.0 // At this offset the Header stops its transformations
let offset_B_LabelHeader:CGFloat = 95.0 // At this offset the Black label reaches the Header
let distance_W_LabelHeader:CGFloat = 35.0 // The distance between the bottom of the Header and the top of the White Label

class TwitterProfileViewController: UIViewController, UIScrollViewDelegate {
    
    //@IBOutlet var scrollView:UIScrollView!
    @IBOutlet weak var avatarImage:UIImageView!
    @IBOutlet weak var header:UIView!
    @IBOutlet weak var headerLabel:UILabel!
    var headerImageView:UIImageView!
    var headerBlurImageView:UIImageView!
    var blurredHeaderImageView:UIImageView?
    
    @IBOutlet weak var tweetsTableView: UITableView!
    @IBOutlet weak var userProfileNameLabel: UILabel!
    @IBOutlet weak var userProfileUserNameLabel: UILabel!
    @IBOutlet weak var userProfileDescription: UILabel!
    @IBOutlet weak var userFollowingCountLabel: UILabel!
    @IBOutlet weak var userFollowersCountLabel: UILabel!
    
    var userTweets: [Tweet]!
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tweetsTableView.delegate = self
        self.tweetsTableView.dataSource = self
        
        self.tweetsTableView.rowHeight = UITableViewAutomaticDimension
        self.tweetsTableView.estimatedRowHeight = 170
        self.avatarImage.layer.cornerRadius = 10.0
        self.avatarImage.layer.borderColor = UIColor.white.cgColor
        self.avatarImage.layer.borderWidth = 3.0
        
        guard let twitterUser: User = self.user else {
            return
        }
        
        guard let user: User = self.user else {
            return
        }
        
        if let userAvatarImageURL: URL = user.profileURL {
            self.avatarImage.setImageWith(userAvatarImageURL)
        }
        
        if let userTagline: String = user.tagline {
            self.userProfileDescription.text = userTagline
        }
        
        if let usersName: String = user.name {
            self.userProfileNameLabel.text = usersName
        }
        
        if let userName: String = user.username {
            self.userProfileUserNameLabel.text = "@\(userName)"
        }
        
        if let formattedFollowingCount: String = user.formattedFollowingCount {
            self.userFollowingCountLabel.text = formattedFollowingCount
        }
        
        if let formattedFollowersCount: String = user.formattedFollowersCount {
            self.userFollowersCountLabel.text = formattedFollowersCount
        }
        
        
        // Header - Image
        
        guard let headerBackdropURL: URL = user.profileBackdropURL else {
            return
        }
        
        let backdropURLRequest: URLRequest = URLRequest(url: headerBackdropURL)
        
        self.headerBlurImageView = UIImageView(frame: header.bounds)
        self.headerImageView = UIImageView(frame: header.bounds)
        
        self.headerImageView.setImageWith(backdropURLRequest, placeholderImage: nil, success: { [weak self] (request: URLRequest, response: HTTPURLResponse?, image: UIImage?) in
            
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.headerImageView.image = image
            strongSelf.headerBlurImageView.image = image?.blurredImage(withRadius: 10, iterations: 20, tintColor: UIColor.clear)
            
            }, failure: { (request: URLRequest, response: HTTPURLResponse?, error: Error) in
                SVProgressHUD.showError(withStatus: error.localizedDescription)
        })
        self.headerImageView?.contentMode = UIViewContentMode.scaleAspectFill
        self.header.insertSubview(self.headerImageView, belowSubview: headerLabel)
        
        // Header - Blurred Image
        self.headerBlurImageView?.contentMode = UIViewContentMode.scaleAspectFill
        self.headerBlurImageView?.alpha = 0.0
        self.header.insertSubview(headerBlurImageView, belowSubview: headerLabel)
        
        self.header.clipsToBounds = true
        
        let twitterClient: TwitterClient = TwitterClient.sharedInstance
        twitterClient.getUsersTweets(twitterUser, startingAtTweetID: nil, success: { (tweets: [Tweet]) in
            self.userTweets = tweets
            self.tweetsTableView.reloadData()
        }, failure: { (error: Error?) in
            // Some sort of error.
            SVProgressHUD.showError(withStatus: error?.localizedDescription)
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let offset = scrollView.contentOffset.y
        var avatarTransform = CATransform3DIdentity
        var headerTransform = CATransform3DIdentity
        
        // PULL DOWN -----------------
        
        if offset < 0 {
            
            let headerScaleFactor:CGFloat = -(offset) / header.bounds.height
            let headerSizevariation = ((header.bounds.height * (1.0 + headerScaleFactor)) - header.bounds.height)/2.0
            headerTransform = CATransform3DTranslate(headerTransform, 0, headerSizevariation, 0)
            headerTransform = CATransform3DScale(headerTransform, 1.0 + headerScaleFactor, 1.0 + headerScaleFactor, 0)
            
            header.layer.transform = headerTransform
        }
            
            // SCROLL UP/DOWN ------------
            
        else {
            
            // Header -----------
            
            headerTransform = CATransform3DTranslate(headerTransform, 0, max(-offset_HeaderStop, -offset), 0)
            
            //  ------------ Label
            
            let labelTransform = CATransform3DMakeTranslation(0, max(-distance_W_LabelHeader, offset_B_LabelHeader - offset), 0)
            headerLabel.layer.transform = labelTransform
            
            //  ------------ Blur
            
            headerBlurImageView?.alpha = min (1.0, (offset - offset_B_LabelHeader)/distance_W_LabelHeader)
            
            // Avatar -----------
            
            let avatarScaleFactor = (min(offset_HeaderStop, offset)) / avatarImage.bounds.height / 1.4 // Slow down the animation
            let avatarSizeVariation = ((avatarImage.bounds.height * (1.0 + avatarScaleFactor)) - avatarImage.bounds.height) / 2.0
            avatarTransform = CATransform3DTranslate(avatarTransform, 0, avatarSizeVariation, 0)
            avatarTransform = CATransform3DScale(avatarTransform, 1.0 - avatarScaleFactor, 1.0 - avatarScaleFactor, 0)
            
            if offset <= offset_HeaderStop {
                
                if avatarImage.layer.zPosition < header.layer.zPosition{
                    header.layer.zPosition = 0
                }
                
            }else {
                if avatarImage.layer.zPosition >= header.layer.zPosition{
                    header.layer.zPosition = 2
                }
            }
        }
        
        // Apply Transformations
        
        header.layer.transform = headerTransform
        avatarImage.layer.transform = avatarTransform
    }
}

extension TwitterProfileViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.userTweets?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TweetTableViewCell = self.tweetsTableView.dequeueReusableCell(withIdentifier: "TweetsTableViewCell") as! TweetTableViewCell
        
        cell.tweetData = self.userTweets[indexPath.row]
        
        return cell
    }
    
}
