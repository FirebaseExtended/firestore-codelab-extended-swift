//  Copyright (c) 2018 Google Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
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

  static func priceString(from price: Int) -> String {
    let priceText: String
    switch price {
    case 1:
      priceText = "$"
    case 2:
      priceText = "$$"
    case 3:
      priceText = "$$$"
    case _:
      // Yeah, we probably don't want to fail in real-life
      fatalError("price must be between one and three")
    }

    return priceText
  }

  static func priceValue(from string: String?) -> Int? {
    guard let string = string else { return nil }
    switch string {
    case "$":
      return 1
    case "$$":
      return 2
    case "$$$":
      return 3

    case _:
      return nil
    }
  }

}

