//
//  ComposeTweetViewController.swift
//  twetter
//
//  Created by Nick McDonald on 2/11/17.
//  Copyright © 2017 Nick McDonald. All rights reserved.
//

import UIKit
import SVProgressHUD

class ComposeTweetViewController: UIViewController {

    @IBOutlet weak var bottomToolBar: UIToolbar!
    @IBOutlet weak var tweetBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var tweetButtonContainerView: UIView!
    @IBOutlet weak var tweetButton: UIButton!
    @IBOutlet weak var tweetCharacterCountLabel: UILabel!
    @IBOutlet weak var tweetTextView: UITextView!
    @IBOutlet weak var toolBarBottomConstraint: NSLayoutConstraint!
    
    var inReplyToTweet: Tweet?
    var currentUser: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tweetTextView.delegate = self

        // Do any additional setup after loading the view.
        self.tweetButton.layer.cornerRadius = 4.0
        self.tweetButton.clipsToBounds = true
        self.tweetTextView.becomeFirstResponder()
        
        self.setInitialText(tweetInReplyTo: self.inReplyToTweet)
        
        if User.currentUser != nil {
            self.currentUser = User.currentUser
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardShown(notification:)), name: .UIKeyboardWillShow, object: nil)
        
        // Setup the navigation bar.
        self.setUpNavigationBarData()
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    private func setInitialText(tweetInReplyTo: Tweet?) {
        
        guard let tweet: Tweet = tweetInReplyTo else {
            self.tweetTextView.text = ""
            return
        }
        
        let userNameOfOriginalTweetAuthor: String = "@\((tweet.tweetAuthor?.username)!) "
        self.tweetTextView.text = userNameOfOriginalTweetAuthor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func setUpNavigationBarData() {
        
        // Set the title.
        self.title = "@\(self.currentUser.username!)"
        
        var profileImageView: UIImageView?
        var currentUserProfileImage: UIImage?
        
        // Now have the current user.
        if let profileImage: UIImage = self.currentUser.cachedProfileImage {
            currentUserProfileImage = profileImage
            profileImageView = UIImageView(image: profileImage)
            self.addProfileImageViewToNavigationBar(profileImageView!)
        } else {
            // Have to fetch the image from the network.
            if let profileImageURL: URL = currentUser.profileURL {
                let profileImageRequest: URLRequest = URLRequest(url: profileImageURL, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10)
                profileImageView = UIImageView()
                profileImageView?.setImageWith(profileImageRequest, placeholderImage: nil, success: {[weak self] (request: URLRequest, response: HTTPURLResponse?, image: UIImage) in
                    
                    currentUserProfileImage = image
                    profileImageView!.image = currentUserProfileImage
                    self?.currentUser.setCachedProfileImage(image: image)
                    self?.addProfileImageViewToNavigationBar(profileImageView!)
                    
                }, failure: { (requese: URLRequest, response: HTTPURLResponse?, error: Error) in
                    // Error here!
                    SVProgressHUD.showError(withStatus: error.localizedDescription)
                })
            }
        }
    }
    
    private func addProfileImageViewToNavigationBar(_ profileImageView: UIImageView) {
        profileImageView.layer.cornerRadius = 4.0
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        let navigationBarHeight = self.navigationController?.navigationBar.frame.height
        let adjustedProfileImageViewHeight = navigationBarHeight! - 16
        let profileImageViewFrame: CGRect = CGRect(x: 8, y: 8, width: adjustedProfileImageViewHeight, height: adjustedProfileImageViewHeight)
        profileImageView.frame = profileImageViewFrame
        self.navigationController?.navigationBar.addSubview(profileImageView)
    }
    
    @IBAction func cancelTweetTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func keyboardShown(notification: Notification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            self.toolBarBottomConstraint.constant = keyboardSize.height
        }
    }

    @IBAction func tweetButtonTapped(_ sender: Any) {
        let twitterClient: TwitterClient = TwitterClient.sharedInstance
        
        twitterClient.tweetWithText(self.tweetTextView.text, inReplyToTweet: self.inReplyToTweet, success: { 
            // Do something!
            SVProgressHUD.showSuccess(withStatus: "")
            self.dismiss(animated: true, completion: nil)
        }) { (error: Error?) in
            SVProgressHUD.showError(withStatus: error?.localizedDescription)
        }
    }
}

extension ComposeTweetViewController: UITextViewDelegate {
    
    private func applyRulesBasedOnTextLength(_ textView: UITextView) {
        let textInTextView: String = textView.text
        let tweetLength: Int = textInTextView.characters.count
        self.tweetCharacterCountLabel.text = "\(tweetLength)/\(maxTweetCharacterSize)"
        if tweetLength > maxTweetCharacterSize || tweetLength == 0 {
            self.tweetButton.isEnabled = false
        } else {
            self.tweetButton.isEnabled = true
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.applyRulesBasedOnTextLength(textView)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.applyRulesBasedOnTextLength(textView)
    }
    
}
