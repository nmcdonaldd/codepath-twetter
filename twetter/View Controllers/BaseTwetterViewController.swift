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
        self.transitionToComposeView(tweet: tweet, userInReplyTo: user, withSender: sender)
    }
    
    private func transitionToComposeView(tweet: Tweet?, userInReplyTo: User?, withSender sender: Any?) {
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
