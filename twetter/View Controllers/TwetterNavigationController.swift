//
//  TwetterNavigationController.swift
//  twetter
//
//  Created by Nick McDonald on 2/10/17.
//  Copyright © 2017 Nick McDonald. All rights reserved.
//

import UIKit

class TwetterNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the tint color for the navigation bar.
        self.navigationBar.barTintColor = defaultAppColor

        // Do any additional setup after loading the view.
        self.delegate = TwetterBarButtonManager.sharedInstance
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
