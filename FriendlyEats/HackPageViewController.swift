//
//  HackPageViewController.swift
//  FriendlyEats
//
//  Created by Todd Kerpelman on 2/6/18.
//  Copyright © 2018 Firebase. All rights reserved.
//

import UIKit

class HackPageViewController: UIViewController {

  static func fromStoryboard(_ storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)) -> HackPageViewController {
    let controller = storyboard.instantiateViewController(withIdentifier: "HackPageViewController") as! HackPageViewController
    return controller
  }


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }


}
