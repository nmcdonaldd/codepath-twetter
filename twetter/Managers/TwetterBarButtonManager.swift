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
        
        UIView.animate(withDuration: 0.3) { 
            if let _: TwitterProfileViewController = viewController as? TwitterProfileViewController {
                navigationController.navigationBar.isTranslucent = true
                navigationController.navigationBar.barTintColor = UIColor.clear
                navigationController.navigationBar.backgroundColor = UIColor.clear
                let backgroundImage: UIImage = UIImage.fromColor(color: UIColor.clear)
                navigationController.navigationBar.setBackgroundImage(backgroundImage, for: .any, barMetrics: .default)
            } else {
                navigationController.navigationBar.isTranslucent = false
                navigationController.navigationBar.barTintColor = defaultAppColor
                navigationController.navigationBar.setBackgroundImage(nil, for: .any, barMetrics: .default)
            }
        }
    }
//    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
//        let colorToChange: UIColor!
//        if let _: TwitterProfileViewController = viewController as? TwitterProfileViewController {
//            colorToChange = UIColor.clear
//        } else {
//            colorToChange = defaultAppColor
//        }
//        
//        UIView.animate(withDuration: 0.3) { 
//            navigationController.navigationBar.barTintColor = colorToChange
//        }
//    }
}
extension UIImage {
    static func fromColor(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}
