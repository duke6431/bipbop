//
//  HelperExts.swift
//  Automation
//
//  Created by Duc Minh Nguyen on 5/2/22.
//

import UIKit

extension UIViewController {
    class func topMostViewController() -> UIViewController? {
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            return topController
        }
        return nil
    }
}
