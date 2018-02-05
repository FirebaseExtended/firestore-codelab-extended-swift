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
    var imagePicker = UIImagePickerController()
    
    // MARK: Outlets
    
    @IBOutlet weak var restaurantImageView: UIImageView!
    @IBOutlet weak var restaurantNameTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var cuisineTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    
    static func fromStoryboard(_ storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)) -> EditRestaurantViewController {
        let controller = storyboard.instantiateViewController(withIdentifier: "EditRestaurantViewController") as! EditRestaurantViewController
        return controller
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let _ = restaurant {
            populateRestaurant()
        }
    }

    // populate restaurant with current data
    func populateRestaurant() {
        restaurantNameTextField.text = restaurant?.name
        locationTextField.text = restaurant?.city
        cuisineTextField.text = restaurant?.category
        priceTextField.text = restaurant?.price.description
        restaurantImageView.sd_setImage(with: restaurant?.photoURL)
    }
    
    func saveChanges() {
        let data = [
            "name": restaurantNameTextField.text,
            "city": locationTextField.text,
            "category": cuisineTextField.text,
            "price": Int(priceTextField.text!)
            //"photoURL": dostuffhere
            ] as [String : Any]
        Firestore.firestore().collection("restaurants").document((restaurant?.documentID)!).updateData(data){ err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                self.handleAlert(isSaving: false)
            }
        }
    }

    func handleAlert(isSaving: Bool) {
        var message = "Are you sure you want to save changes to this restaurant?"
        if !isSaving {
            message = "Successfully saved!"
        }
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { action in
            self.saveChanges()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "OK", style: .default) { action in
            self.navigationController?.popViewController(animated: true)
        }
        if isSaving {
            alertController.addAction(saveAction)
            alertController.addAction(cancelAction)
        } else {
            alertController.addAction(okAction)
        }
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func selectNewImage(_ sender: Any) {
        selectImage()
    }
    
    @IBAction func didSelectSaveChanges(_ sender: Any) {
        handleAlert(isSaving: true)
    }
    
}

extension EditRestaurantViewController: UIImagePickerControllerDelegate {
    
    func selectImage() {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            
            imagePicker.delegate = self as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
            imagePicker.sourceType = .savedPhotosAlbum;
            imagePicker.allowsEditing = false
            
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: NSDictionary!){
        self.dismiss(animated: true, completion: { () -> Void in
            // save image
        })
    }
}
