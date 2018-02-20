//  Copyright (c) 2016 Google Inc.
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
import Firebase
import FirebaseStorage

class AddRestaurantViewController: UIViewController, UINavigationControllerDelegate {

  // MARK: Properties

  private var user: User!
  private lazy var restaurant: Restaurant = {
    return Restaurant(ownerID: user.userID, name: "", category: "", city: "", price: 0, reviewCount: 0, averageRating: 0, photoURL: Restaurant.randomPhotoURL())
  }()
  private var imagePicker = UIImagePickerController()
  private var downloadUrl: String?

  // MARK: Outlets

  @IBOutlet private weak var restaurantImageView: UIImageView!
  @IBOutlet private weak var restaurantNameTextField: UITextField!
  @IBOutlet private weak var locationTextField: UITextField!
  @IBOutlet private weak var cuisineTextField: UITextField!
  @IBOutlet private weak var priceTextField: UITextField!
  @IBOutlet fileprivate weak var addPhotoButton: UIButton!

  static func fromStoryboard(_ storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil))
      -> AddRestaurantViewController {
    let controller = storyboard.instantiateViewController(withIdentifier: "AddRestaurantViewController")
      as! AddRestaurantViewController
    return controller
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    user = User(user: Auth.auth().currentUser!)
    restaurantImageView.contentMode = .scaleAspectFill
    restaurantImageView.clipsToBounds = true
    hideKeyboardWhenTappedAround()
  }

  func saveChanges() {
    guard let name = restaurantNameTextField.text,
      let city = locationTextField.text,
      let category = cuisineTextField.text,
      let price = priceTextField.text.flatMap(Int.init) else {
        self.presentInvalidDataAlert(message: "All fields must be filled out and price must be an integer from 1 to 3.")
        return
    }
    restaurant.name = name
    restaurant.city = city
    restaurant.category = category
    restaurant.price = price
    // if photo was changed, add the new url
    if let downloadUrl = downloadUrl {
      restaurant.photoURL = URL(string: downloadUrl)!
    }
    print("Going to save document data as \(restaurant.documentData)")
    Firestore.firestore().restaurants.document(restaurant.documentID)
        .setData(restaurant.documentData) { err in
          if let err = err {
            print("Error writing document: \(err)")
          } else {
            self.presentDidSaveAlert()
          }
    }
  }

  // MARK: Alert Messages

  func presentDidSaveAlert() {
    let message = "Restaurant added successfully!"
    let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
    let okAction = UIAlertAction(title: "OK", style: .default) { action in
      self.navigationController?.popViewController(animated: true)
    }
    alertController.addAction(okAction)
    self.present(alertController, animated: true, completion: nil)
  }

  // If data in text fields isn't valid, give an alert
  func presentInvalidDataAlert(message: String) {
    Utils.showSimpleAlert(title: "Invalid Input", message: message, presentingVC: self)
  }

  func saveImage(photoData: Data) {
    Storage.storage().reference(withPath: restaurant.documentID).putData(photoData, metadata: nil) { (metadata, error) in
      if let error = error {
        print(error)
      }
      guard let metadata = metadata else {
        return
      }
      self.downloadUrl = metadata.downloadURL()?.absoluteString
    }
  }

  // MARK: Keyboard functionality

  @objc func inputToolbarDonePressed() {
    resignFirstResponder()
  }

  @objc func keyboardNextButton() {
    if locationTextField.isFirstResponder {
      cuisineTextField.becomeFirstResponder()
    } else if cuisineTextField.isFirstResponder {
      priceTextField.becomeFirstResponder()
    } else if restaurantNameTextField.isFirstResponder {
      locationTextField.becomeFirstResponder()
    } else {
      resignFirstResponder()
    }
  }

  @objc func keyboardPreviousButton() {
    if locationTextField.isFirstResponder {
      restaurantNameTextField.becomeFirstResponder()
    } else if cuisineTextField.isFirstResponder {
      locationTextField.becomeFirstResponder()
    } else if priceTextField.isFirstResponder {
      cuisineTextField.becomeFirstResponder()
    } else {
      resignFirstResponder()
    }
  }

  lazy var inputToolbar: UIToolbar = {
    let toolbar = UIToolbar()
    toolbar.barStyle = .default
    toolbar.isTranslucent = true
    toolbar.sizeToFit()

    var doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.inputToolbarDonePressed))
    var flexibleSpaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    var fixedSpaceButton = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)

    var nextButton  = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_keyboard_arrow_left"), style: .plain, target: self, action: #selector(self.keyboardPreviousButton))
    nextButton.width = 50.0
    var previousButton  = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_keyboard_arrow_right"), style: .plain, target: self, action: #selector(self.keyboardNextButton))

    toolbar.setItems([fixedSpaceButton, nextButton, fixedSpaceButton, previousButton, flexibleSpaceButton, doneButton], animated: false)
    toolbar.isUserInteractionEnabled = true

    return toolbar
  }()

  // MARK: IBActions

  @IBAction func selectNewImage(_ sender: Any) {
    selectImage()
  }

  @IBAction func didPressSaveButton(_ sender: Any) {
    saveChanges()
  }

}

extension AddRestaurantViewController: UITextFieldDelegate {

  func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    textField.inputAccessoryView = inputToolbar
    return true
  }

  func textFieldDidEndEditing(_ textField: UITextField) {
    let text = textField.text?.trimmingCharacters(in: .whitespaces)
    if textField == priceTextField {
      if text != "1" && text != "2" && text != "3" {
        // return to previous text
        textField.text = restaurant.price.description
        presentInvalidDataAlert(message: "Invalid price. Please enter a number from 1 to 3.")
        return
      }
    }
  }

  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
}

extension AddRestaurantViewController: UIImagePickerControllerDelegate {

  func selectImage() {
    imagePicker.delegate = self
    if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){

      imagePicker.sourceType = .savedPhotosAlbum;
      imagePicker.allowsEditing = false

      self.present(imagePicker, animated: true, completion: nil)
    }
  }

  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {

    if let photo = info[UIImagePickerControllerOriginalImage] as? UIImage, let photoData = UIImageJPEGRepresentation(photo, 0.8) {
      self.restaurantImageView.image = photo
      self.addPhotoButton.titleLabel?.text = ""
      self.addPhotoButton.backgroundColor = UIColor.clear
      saveImage(photoData: photoData)
    }
    self.dismiss(animated: true, completion: nil)
  }
}
