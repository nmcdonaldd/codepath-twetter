//
//  BaseTwetterViewController.swift
//  twetter
//
//  Created by Nick McDonald on 2/10/17.
//  Copyright © 2017 Nick McDonald. All rights reserved.
//

import UIKit

/*
    BaseTwetterViewController
        - This is the base UIViewController of the subsequent ViewControllers.
        - Subclassing this VC will mean that viewController will show the "compose tweet" function in top right navigation bar.
 */

class BaseTwetterViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func composeTweetButtonTapped() {
        self.presentComposeTweetToUser(nil, orInReplyTo: nil, withSender: nil)
    }
    
    func presentComposeTweetToUser(_ user: User?, orInReplyTo tweet: Tweet?, withSender sender: Any?) {
        var userToReplyTo: User? = user
        
        checkingTwitterUserIDLabel: if let userInReplyTo: User = userToReplyTo {
            guard let currentUserID: String = User.currentUser?.userID, let profileViewingUserID: String = userInReplyTo.userID else {
                break checkingTwitterUserIDLabel
            }
            if currentUserID == profileViewingUserID {
                userToReplyTo = nil
            }
        }
        self.transitionToComposeView(inReplyToTweet: tweet, userInReplyTo: userToReplyTo, withSender: sender)
    }
    
    private func transitionToComposeView(inReplyToTweet tweet: Tweet?, userInReplyTo: User?, withSender sender: Any?) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let composeTweetNavVC: TwetterNavigationController = storyboard.instantiateViewController(withIdentifier: modalTweetVCIdentifier) as! TwetterNavigationController
        composeTweetNavVC.modalPresentationStyle = .popover
        let composeTweetVC: ComposeTweetViewController = composeTweetNavVC.topViewController as! ComposeTweetViewController
        if let possibleDelegate: ComposeTweetDelegate = sender as? ComposeTweetDelegate {
            composeTweetVC.delegate = possibleDelegate
        }
        composeTweetVC.inReplyToTweet = tweet
        composeTweetVC.toUser = userInReplyTo
        self.present(composeTweetNavVC, animated: true, completion: nil)
    }
}
