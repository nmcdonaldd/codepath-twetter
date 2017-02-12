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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tweetsTableView.delegate = self
        self.tweetsTableView.dataSource = self
        
        self.tweetsTableView.rowHeight = UITableViewAutomaticDimension
        self.tweetsTableView.estimatedRowHeight = 170
        self.tweetsTableView.isHidden = true
        
        UIApplication.shared.statusBarStyle = .lightContent
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        // Load the image for the title.
        let titleImageView: UIImageView = UIImageView(image: UIImage(imageLiteralResourceName: "StackOfTweets"))
        self.navigationItem.titleView = titleImageView
        
        self.loadTweets()
    }
    
    private func loadTweets() {
        // Setup & show the loading HUD
        self.setUpLoadingHUD()
        SVProgressHUD.show()
        
        TwitterClient.sharedInstance.homeTimeline(success: { [weak self] (tweets: [Tweet]) in
            
            // Unlikely to get a strong reference cycle, but let's be conservative.
            if let strongSelf = self {
                if (!(strongSelf.navigationItem.rightBarButtonItem?.isEnabled)!) {
                    strongSelf.navigationItem.rightBarButtonItem?.isEnabled = true
                }
                
                strongSelf.tweets = tweets
                strongSelf.doneLoadingInitialData()
                strongSelf.tweetsTableView.reloadData()
            }
            
        }) { (error: Error) in
            SVProgressHUD.dismiss()
            SVProgressHUD.showError(withStatus: error.localizedDescription)
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        }
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
        
        cell.tweetData = self.tweets[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
