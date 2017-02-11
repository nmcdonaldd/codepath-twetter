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
    
    var tweets: [Tweet]!
    @IBOutlet weak var tweetsTableView: UITableView!
    @IBOutlet weak var loadingTweetsFailedView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tweetsTableView.delegate = self
        self.tweetsTableView.dataSource = self
        
        self.tweetsTableView.rowHeight = UITableViewAutomaticDimension
        self.tweetsTableView.estimatedRowHeight = 170
        self.tweetsTableView.isHidden = true
        
        UIApplication.shared.statusBarStyle = .lightContent
        
        let title: String = "Home"
        self.title = title

        // Load the image for the title.
        let titleImageView: UIImageView = UIImageView(image: UIImage(imageLiteralResourceName: "StackOfTweets"))
        self.navigationItem.titleView = titleImageView
        
        self.loadTweets()
    }
    
    func retryLoadingTweetsTapped() {
        SVProgressHUD.dismiss()
        self.loadTweets()
    }
    
    private func loadTweets() {
        // Setup & show the loading HUD
        self.setUpLoadingHUD()
        SVProgressHUD.show()
        
        TwitterClient.sharedInstance.homeTimeline(success: { [weak self] (tweets: [Tweet]) in
            
            // Unlikely to get a reference cycle, but let's be conservative.
            if let strongSelf = self {
                strongSelf.tweets = tweets
                strongSelf.doneLoadingInitialData()
                strongSelf.tweetsTableView.reloadData()
            }
            
        }) { (error: Error) in
            SVProgressHUD.dismiss()
            SVProgressHUD.showError(withStatus: error.localizedDescription)
        }
    }
    
    private func showRetryLoadingTweetsAction() {
        // TODO: - Show something for the user to retry.
        
    }
    
    private func setUpLoadingHUD() {
        SVProgressHUD.setDefaultStyle(.custom)
        SVProgressHUD.setBackgroundColor(UIColor.clear)
        SVProgressHUD.setForegroundColor(defaultAppColor)
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
        
        cell.tweetData = self.tweets[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
