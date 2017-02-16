//
//  LoginViewController.swift
//  twetter
//
//  Created by Nick McDonald on 1/29/17.
//  Copyright © 2017 Nick McDonald. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Change the status bar color.
        UIApplication.shared.statusBarStyle = .lightContent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onLoginButtonTapped(_ sender: Any) {
        
        let twitterClient: TwitterClient = TwitterClient.sharedInstance
        twitterClient.login(success: {
            self.performSegue(withIdentifier: "loginSegue", sender: nil)
        }) { (error: Error?) in
            print("Error: \(error?.localizedDescription)")
        }
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
