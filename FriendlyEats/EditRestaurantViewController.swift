//
//  EditRestaurantViewController.swift
//  FriendlyEats
//
//  Created by Jen Person on 2/5/18.
//  Copyright © 2018 Firebase. All rights reserved.
//

import UIKit
import Firebase

class EditRestaurantViewController: UIViewController {

    // MARK: Properties
    var restaurant: Restaurant?
    
    // MARK: Outlets
    
    @IBOutlet weak var restaurantImageView: UIImageView!
    @IBOutlet weak var restaurantNameTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var cuisineTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    func populateRestaurant() {
        restaurantNameTextField.text = restaurant?.name
        locationTextField.text = restaurant?.city
        cuisineTextField.text = restaurant?.category
        priceTextField.text = restaurant?.price
        restaurantImageView.sd_setImage(with: restaurant?.photoURL)
    }

    @IBAction func selectNewImage(_ sender: Any) {
        
    }
}
