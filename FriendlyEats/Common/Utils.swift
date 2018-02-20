//
//  Utils.swift
//  FriendlyEats
//
//  Created by Todd Kerpelman on 2/20/18.
//  Copyright © 2018 Firebase. All rights reserved.
//

import UIKit

class Utils: NSObject {

  static func showSimpleAlert(message: String, presentingVC: UIViewController) {
    Utils.showSimpleAlert(title: nil, message: message, presentingVC: presentingVC)
  }

  static func showSimpleAlert(title: String?, message: String, presentingVC: UIViewController) {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let okAction = UIAlertAction(title: "OK", style: .default)
    alertController.addAction(okAction)
    presentingVC.present(alertController, animated: true, completion: nil)
  }
}

