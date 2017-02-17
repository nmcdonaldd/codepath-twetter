//
//  TwitterProfileViewController.swift
//  twetter
//
//  Created by Nick McDonald on 2/12/17.
//  Copyright © 2017 Nick McDonald. All rights reserved.
//

import UIKit
import SVProgressHUD

// NOTE: The twitter profile was adapted from a tutorial here: http://www.thinkandbuild.it/implementing-the-twitter-ios-app-ui/.
// It doesn't fully work on larger phone sizes. I didn't have time to fix it, really :(

let offset_HeaderStop:CGFloat = 40.0 // At this offset the Header stops its transformations
let offset_B_LabelHeader:CGFloat = 95.0 // At this offset the Black label reaches the Header
let distance_W_LabelHeader:CGFloat = 35.0 // The distance between the bottom of the Header and the top of the White Label

class TwitterProfileViewController: BaseTwetterViewController {
    
    static private let followingString: String = "Following"
    static private let followString: String = "Follow"
    
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var header: UIView!
    @IBOutlet weak var headerLabel: UILabel!
    var headerImageView:UIImageView!
    var headerBlurImageView:UIImageView!
    
    @IBOutlet weak var tableHeaderView: UIView!
    @IBOutlet weak var tweetsTableView: UITableView!
    @IBOutlet weak var userProfileNameLabel: UILabel!
    @IBOutlet weak var userProfileUserNameLabel: UILabel!
    @IBOutlet weak var userProfileDescription: UILabel!
    @IBOutlet weak var userFollowingCountLabel: UILabel!
    @IBOutlet weak var userFollowersCountLabel: UILabel!
    
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    fileprivate var loadingMoreDataActivityView: InfiniteScrollActivityView!
    fileprivate var isInfiniteScrolling: Bool = false
    fileprivate var isLoadingMoreData: Bool = false
    fileprivate var selectedIndexPath: IndexPath?
    private var refreshControl: UIRefreshControl!
    @IBOutlet weak var followButton: TwetterFollowingButtonView!
    
    var userTweets: [Tweet]!
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setUpRefreshControl()
        self.tweetsTableView.delegate = self
        self.tweetsTableView.dataSource = self
        
        self.tweetsTableView.rowHeight = UITableViewAutomaticDimension
        self.tweetsTableView.estimatedRowHeight = 170
        
        guard let _: User = self.user else {
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
            self.headerLabel.text = usersName
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
        
        if user.username == User.currentUser?.username! {
            self.followButton.isHidden = true
        } else {
            var followButtonType: TwetterFollowingButtonType
            var followingString: String!
            if user.isFollowing {
                followButtonType = .following
                followingString = TwitterProfileViewController.followingString
            } else {
                followButtonType = .notFollowing
                followingString = TwitterProfileViewController.followString
            }
            self.followButton.setButtonTypeWithTitle(followButtonType, title: followingString)
        }
        
        let backBarButtonItem: UIBarButtonItem = UIBarButtonItem(title: "@\(user.username!)", style: .plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = backBarButtonItem
        
        
        // Header - Image
        
        guard let headerBackdropURL: URL = user.profileBackdropURL else {
            SVProgressHUD.showError(withStatus: "Error loading user")
            return
        }
        
        let backdropURLRequest: URLRequest = URLRequest(url: headerBackdropURL)
        
        self.headerBlurImageView = UIImageView(frame: header.bounds)
        self.headerImageView = UIImageView(frame: header.bounds)
        
        self.headerImageView.setImageWith(backdropURLRequest, placeholderImage: nil, success: { (request: URLRequest, response: HTTPURLResponse?, image: UIImage?) in
            
            self.headerImageView?.image = image
            self.headerBlurImageView?.image = image?.blurredImage(withRadius: 10, iterations: 20, tintColor: UIColor.clear)
            self.header.insertSubview(self.headerImageView, belowSubview: self.headerLabel)
            self.header.insertSubview(self.headerBlurImageView, belowSubview: self.headerLabel)
            
            }, failure: { (request: URLRequest, response: HTTPURLResponse?, error: Error) in
                SVProgressHUD.showError(withStatus: error.localizedDescription)
        })
        
        self.headerImageView?.contentMode = UIViewContentMode.scaleAspectFill
        
        // Header - Blurred Image
        self.headerBlurImageView?.contentMode = UIViewContentMode.scaleAspectFill
        self.headerBlurImageView?.alpha = 0.0
        
        self.header.clipsToBounds = true
        
        self.tweetsTableView.tableHeaderView = self.tableHeaderView
        self.loadUserTweets()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let headerView: UIView = self.tweetsTableView.tableHeaderView {
            let height = headerView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
            var headerFrame: CGRect = headerView.frame
            
            if height != headerFrame.size.height {
                headerFrame.size.height = height
                headerView.frame = headerFrame
                
                self.tweetsTableView.tableHeaderView = headerView
            }
        }
    }
    
    
    @objc fileprivate func loadUserTweets() {
        
        let tweetOffset: String? = self.isInfiniteScrolling ? self.userTweets?.last?.tweetID ?? nil : nil
        
        guard let user: User = self.user else {
            return
        }
        
        user.getUserTweets(startingAtTweetIDOffset: tweetOffset, success: { (tweets: [Tweet]) in
            
            var tweetsReturned: [Tweet] = tweets
            if self.isInfiniteScrolling {
                // The tweets returned will have the last one that we already have.
                // Thus, lets purge the first one.
                if let tweetIDOfFirstTweet: String = tweetsReturned.first?.tweetID {
                    if tweetIDOfFirstTweet == tweetOffset {
                        tweetsReturned.remove(at: 0)
                    }
                }
                self.userTweets? += tweetsReturned
                self.isInfiniteScrolling = false
            } else {
                self.userTweets = tweetsReturned
            }
            self.refreshControl.endRefreshing()
            self.tweetsTableView.reloadData()
        }) { (error: Error?) in
            self.refreshControl.endRefreshing()
            SVProgressHUD.showError(withStatus: error?.localizedDescription)
        }
    }
    
    private func setUpRefreshControl() {
        self.refreshControl = UIRefreshControl()
        self.refreshControl.backgroundColor = UIColor.clear
        self.refreshControl.tintColor = UIColor.lightGray
        self.refreshControl.addTarget(self, action: #selector(TwitterProfileViewController.loadUserTweets), for: .valueChanged)
        self.tweetsTableView.refreshControl = self.refreshControl
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc: TweetDetailsViewController = segue.destination as! TweetDetailsViewController
        let cell: TweetTableViewCell = sender as! TweetTableViewCell
        let indexPath: IndexPath = self.tweetsTableView.indexPath(for: cell)!
        let tweet: Tweet = self.userTweets[indexPath.row]
        vc.delegate = self
        
        vc.tweetData = tweet
    }
    
    @IBAction func followButtonTapped(_ sender: Any) {
        guard let user: User = self.user else {
            return
        }
        
        user.toggleFollow(success: { 
            // Toggle the button.
            self.userFollowersCountLabel.text = user.formattedFollowersCount
            var twetterButtonType: TwetterFollowingButtonType = .notFollowing
            var followString: String
            if user.isFollowing {
                twetterButtonType = .following
                followString = TwitterProfileViewController.followingString
            } else {
                twetterButtonType = .notFollowing
                followString = TwitterProfileViewController.followString
            }
            self.followButton.setButtonTypeWithTitle(twetterButtonType, title: followString)
        }) { (error: Error?) in
            SVProgressHUD.showError(withStatus: error?.localizedDescription)
        }
    }
    
    override func composeTweetButtonTapped() {
        self.presentComposeTweetToUser(self.user, orInReplyTo: nil, withSender: self)
    }
}

extension TwitterProfileViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let offset = scrollView.contentOffset.y
        var avatarTransform = CATransform3DIdentity
        var headerTransform = CATransform3DIdentity
        
        // Pull down.
        if offset < 0 {
            
            let headerScaleFactor:CGFloat = -(offset) / header.bounds.height
            let headerSizevariation = ((header.bounds.height * (1.0 + headerScaleFactor)) - header.bounds.height)/2.0
            headerTransform = CATransform3DTranslate(headerTransform, 0, headerSizevariation, 0)
            headerTransform = CATransform3DScale(headerTransform, 1.0 + headerScaleFactor, 1.0 + headerScaleFactor, 0)
            header.layer.transform = headerTransform
            
        } else {
            
            headerTransform = CATransform3DTranslate(headerTransform, 0, max(-offset_HeaderStop, -offset), 0)
            
            let labelTransform = CATransform3DMakeTranslation(0, max(-distance_W_LabelHeader, offset_B_LabelHeader - offset), 0)
            headerLabel.layer.transform = labelTransform
            
            headerBlurImageView?.alpha = min (1.0, (offset - offset_B_LabelHeader)/distance_W_LabelHeader)
            
            let avatarScaleFactor = (min(offset_HeaderStop, offset)) / avatarImage.bounds.height / 1.4 // Slow down the animation
            let avatarSizeVariation = ((avatarImage.bounds.height * (1.0 + avatarScaleFactor)) - avatarImage.bounds.height) / 2.0
            avatarTransform = CATransform3DTranslate(avatarTransform, 0, avatarSizeVariation, 0)
            avatarTransform = CATransform3DScale(avatarTransform, 1.0 - avatarScaleFactor, 1.0 - avatarScaleFactor, 0)
            
            if offset <= offset_HeaderStop {
                if avatarImage.layer.zPosition < header.layer.zPosition{
                    header.layer.zPosition = 0
                }
            } else {
                if avatarImage.layer.zPosition >= header.layer.zPosition{
                    header.layer.zPosition = 2
                }
            }
        }
        
        // Apply Transformations
        header.layer.transform = headerTransform
        avatarImage.layer.transform = avatarTransform
        
        if (!self.isLoadingMoreData) {
            let scrollViewContentHeight = self.tweetsTableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - self.tweetsTableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && self.tweetsTableView.isDragging) {
                self.isLoadingMoreData = true
                let frame = CGRect(x: 0, y: self.tweetsTableView.contentSize.height, width: self.tweetsTableView.bounds.width, height: InfiniteScrollActivityView.defaultDrawHeight)
                self.loadingMoreDataActivityView?.frame = frame
                self.loadingMoreDataActivityView?.startAnimating()
                self.isInfiniteScrolling = true
                self.loadUserTweets()
            }
        }
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tweetsTableView.deselectRow(at: indexPath, animated: true)
        self.selectedIndexPath = indexPath
    }
}

extension TwitterProfileViewController: TweetDetailsViewControllerDelegate {
    func tweetDetailsViewControllerDidUpdateRTOrFavoriteValue() {
        if let selectIndexPath = self.selectedIndexPath {
            self.tweetsTableView.reloadRows(at: [selectIndexPath], with: .automatic)
        }
    }
}

extension TwitterProfileViewController: ComposeTweetDelegate {
    func ComposeTweetViewController(_ composeTweetVC: ComposeTweetViewController, willExitWithSuccessfulTweet tweet: Tweet) {
        self.userTweets.insert(tweet, at: 0)
        let indexPath: IndexPath = IndexPath(row: 0, section: 0)
        self.tweetsTableView.insertRows(at: [indexPath], with: .automatic)
    }
}
