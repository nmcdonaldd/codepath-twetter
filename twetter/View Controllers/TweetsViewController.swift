//
//  TweetsViewController.swift
//  twetter
//
//  Created by Nick McDonald on 1/30/17.
//  Copyright © 2017 Nick McDonald. All rights reserved.
//

import UIKit
import SVProgressHUD

class TweetsViewController: BaseTwetterViewController {
    
    var tweets: [Tweet]! {
        didSet {
            self.currentTweetsOffset = self.tweets.count
        }
    }
    @IBOutlet weak var tweetsTableView: UITableView!
    private var refreshControl: UIRefreshControl!
    private var currentTweetsOffset: Int = 0
    fileprivate var loadingMoreDataActivityView: InfiniteScrollActivityView!
    fileprivate var isInfiniteScrolling: Bool = false
    fileprivate var isLoadingMoreData: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tweetsTableView.delegate = self
        self.tweetsTableView.dataSource = self
        
        self.tweetsTableView.rowHeight = UITableViewAutomaticDimension
        self.tweetsTableView.estimatedRowHeight = 170
        self.tweetsTableView.isHidden = true
        self.setUpRefreshControl()
        
        UIApplication.shared.statusBarStyle = .lightContent
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        // Load the image for the title.
        let titleImageView: UIImageView = UIImageView(image: UIImage(imageLiteralResourceName: "StackOfTweets"))
        self.navigationItem.titleView = titleImageView
        
        self.loadTweets()
    }
    
    private func setUpRefreshControl() {
        self.refreshControl = UIRefreshControl()
        self.refreshControl.backgroundColor = UIColor.clear
        self.refreshControl.tintColor = UIColor.lightGray
        self.refreshControl.addTarget(self, action: #selector(TweetsViewController.loadTweets), for: .valueChanged)
        self.tweetsTableView.refreshControl = self.refreshControl
    }
    
    @objc fileprivate func loadTweets() {
        // Setup & show the loading HUD
        //SVProgressHUD.show()
        
        let tweetOffset: String? = self.isInfiniteScrolling ? self.tweets?.last?.tweetID ?? nil : nil
        
        TwitterClient.sharedInstance.homeTimeline(startingAtTweetID: tweetOffset, success: { [weak self] (tweets: [Tweet]) in
            
            // Unlikely to get a strong reference cycle, but let's be conservative.
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.navigationItem.rightBarButtonItem?.isEnabled = true
            if (!(strongSelf.navigationItem.rightBarButtonItem?.isEnabled)!) {
                strongSelf.navigationItem.rightBarButtonItem?.isEnabled = true
            }
            
            if (strongSelf.isInfiniteScrolling) {
                strongSelf.tweets! += tweets
                strongSelf.isInfiniteScrolling = false
            } else {
                strongSelf.tweets = tweets
            }
            
            strongSelf.navigationItem.rightBarButtonItem?.isEnabled = true
            strongSelf.tweets = tweets
            strongSelf.doneLoadingInitialData()
            strongSelf.tweetsTableView.reloadData()
            strongSelf.isLoadingMoreData = false
            strongSelf.refreshControl.endRefreshing()
        
        }) { [weak self] (error: Error) in
            guard let strongSelf = self else {
                return
            }
            strongSelf.refreshControl.endRefreshing()
            strongSelf.isLoadingMoreData = false
            SVProgressHUD.dismiss()
            SVProgressHUD.showError(withStatus: error.localizedDescription)
            strongSelf.navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // TODO: - THIS IS NO LONGER HOOKED UP TO ANYTHING!
    @IBAction func onLogoutTapped(_ sender: Any) {
        TwitterClient.sharedInstance.logout()
    }
    
    private func doneLoadingInitialData() {
        SVProgressHUD.dismiss()
        self.tweetsTableView.isHidden = false
    }
    
    private func setUpInfiniteScrollingLoadingIndicator() {
        let frame = CGRect(x: 0, y: self.tweetsTableView.contentSize.height, width: self.tweetsTableView.bounds.size.width, height: InfiniteScrollActivityView.defaultDrawHeight)
        self.loadingMoreDataActivityView = InfiniteScrollActivityView(frame: frame)
        self.loadingMoreDataActivityView!.isHidden = true
        self.tweetsTableView.addSubview(self.loadingMoreDataActivityView!)
        
        var insets = self.tweetsTableView.contentInset;
        insets.bottom += InfiniteScrollActivityView.defaultDrawHeight;
        self.tweetsTableView.contentInset = insets
    }
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc: TweetDetailsViewController = segue.destination as! TweetDetailsViewController
        let cell: TweetTableViewCell = sender as! TweetTableViewCell
        let indexPath: IndexPath = self.tweetsTableView.indexPath(for: cell)!
        let tweet: Tweet = self.tweets[indexPath.row]
        
        vc.tweetData = tweet
    }
    
}

extension TweetsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let tweets = self.tweets {
            return tweets.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TweetTableViewCell = self.tweetsTableView.dequeueReusableCell(withIdentifier: "TweetsTableViewCell", for: indexPath) as! TweetTableViewCell
        
        cell.delegate = self
        cell.tweetData = self.tweets[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension TweetsViewController: TweetTableViewCellDelegate{

    // TweetTableViewCellDelegate
    func TweetTableViewCellProfileImageWasTapped(_ cell: TweetTableViewCell) {
        let indexPath: IndexPath = self.tweetsTableView.indexPath(for: cell)!
        guard let userTapped: User = self.tweets[indexPath.row].tweetAuthor else {
            return
        }
        let navVC: TwetterNavigationController = self.navigationController as! TwetterNavigationController
        navVC.pushProfileViewControllerOfUser(userTapped)
    }
}

extension TweetsViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
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
                self.loadTweets()
            }
        }
    }
}
