//
//  TwetterBarButtonManager.swift
//  twetter
//
//  Created by Nick McDonald on 2/10/17.
//  Copyright © 2017 Nick McDonald. All rights reserved.
//

import UIKit

class TwetterBarButtonManager: NSObject {
    
    // This will be the shared "Compose Tweet" bar button item on the right of the navigation controller.
    private var sharedComposeTweetRightBarItem: UIBarButtonItem?
    
    // Shared instance of a bar button manager.
    static let sharedInstance: TwetterBarButtonManager = TwetterBarButtonManager()
    
    // Override the init and make it private so that only this class can make a TwetterBarButtonManager.
    private override init() { }
    
    func sharedRightBarItem() -> UIBarButtonItem {
        
        guard let sharedRightBarItem = self.sharedComposeTweetRightBarItem else {
            
            // We need to make our barButtonItem here.
            let composeTweetImage: UIImage = UIImage(imageLiteralResourceName: "ComposeTweet")
            let barButtonItem: UIBarButtonItem = UIBarButtonItem(image: composeTweetImage, style: .plain, target: nil, action: nil)
            return barButtonItem
        }
        return sharedRightBarItem
    }
}

extension TwetterBarButtonManager: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if let destVC: BaseTwetterViewController = viewController as? BaseTwetterViewController {
            navigationController.topViewController?.navigationItem.rightBarButtonItem = nil
            let sharedRightBarButtonItem: UIBarButtonItem = self.sharedRightBarItem()
            
            // Set up the target and action!
            sharedRightBarButtonItem.target = destVC
            sharedRightBarButtonItem.action = #selector(BaseTwetterViewController.composeTweetButtonTapped)
            
            // Set the right bar button item of the destinationVC as the compose button!
            destVC.navigationItem.setRightBarButton(sharedRightBarButtonItem, animated: true)
        }
        
        self.updateNavBarFromNavController(navigationController, forViewController: viewController)
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        self.updateNavBarFromNavController(navigationController, forViewController: viewController)
    }
    
    private func updateNavBarFromNavController(_ navigationController: UINavigationController, forViewController viewController: UIViewController) {
        if let _: TwitterProfileViewController = viewController as? TwitterProfileViewController {
            navigationController.navigationBar.setBackgroundImage(UIImage(), for: .default)
            navigationController.navigationBar.shadowImage = UIImage()
            navigationController.navigationBar.isTranslucent = true
            navigationController.view.backgroundColor = .clear
        } else {
            navigationController.navigationBar.isTranslucent = false
            navigationController.navigationBar.barTintColor = defaultAppColor
            navigationController.navigationBar.setBackgroundImage(nil, for: .any, barMetrics: .default)
        }
    }
}
