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

class AddRestaurantViewController: UIViewController, UINavigationControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate {

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
  @IBOutlet private weak var cityTextField: UITextField! {
    didSet {
      cityTextField.inputView = cityPickerView
    }
  }
  @IBOutlet private weak var categoryTextField: UITextField! {
    didSet {
      categoryTextField.inputView = categoryPickerView
    }
  }
  @IBOutlet private weak var priceTextField: UITextField! {
    didSet {
      priceTextField.inputView = pricePickerView
    }
  }
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
      let city = cityTextField.text,
      let category = categoryTextField.text,
      let price = Utils.priceValue(from: priceTextField.text) else {
        self.presentInvalidDataAlert(message: "All fields must be filled out.")
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
        .setData(restaurant.documentData) { error in
          if let error = error {
            print("Error writing document: \(error)")
          } else {
            print("Write confirmed by the server")
          }
    }
    self.presentDidSaveAlert()
  }


  // MARK: Setting up pickers
  private let priceOptions = ["$", "$$", "$$$"]
  private let cityOptions = Restaurant.cities
  private let categoryOptions = Restaurant.categories

  private lazy var cityPickerView: UIPickerView = {
    let pickerView = UIPickerView()
    pickerView.dataSource = self
    pickerView.delegate = self
    return pickerView
  }()

  private lazy var categoryPickerView: UIPickerView = {
    let pickerView = UIPickerView()
    pickerView.dataSource = self
    pickerView.delegate = self
    return pickerView
  }()

  private lazy var pricePickerView: UIPickerView = {
    let pickerView = UIPickerView()
    pickerView.dataSource = self
    pickerView.delegate = self
    return pickerView
  }()
 // MARK: UIPickerViewDataSource

  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }

  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    switch pickerView {
    case pricePickerView:
      return priceOptions.count
    case cityPickerView:
      return cityOptions.count
    case categoryPickerView:
      return categoryOptions.count

    case _:
      fatalError("Unhandled picker view: \(pickerView)")
    }
  }

  // MARK: - UIPickerViewDelegate

  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent: Int) -> String? {
    switch pickerView {
    case pricePickerView:
      return priceOptions[row]
    case cityPickerView:
      return cityOptions[row]
    case categoryPickerView:
      return categoryOptions[row]
    case _:
      fatalError("Unhandled picker view: \(pickerView)")
    }
  }

  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    switch pickerView {
    case pricePickerView:
      priceTextField.text = priceOptions[row]
    case cityPickerView:
      cityTextField.text = cityOptions[row]
    case categoryPickerView:
      categoryTextField.text = categoryOptions[row]
    case _:
      fatalError("Unhandled picker view: \(pickerView)")
    }
  }


  // MARK: Alert Messages

  func presentDidSaveAlert() {
    let message = "Restaurant added successfully!"
    let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
    let okAction = UIAlertAction(title: "OK", style: .default) { action in
      self.performSegue(withIdentifier: "unwindToMyRestaurantsSegue", sender: self)
    }
    alertController.addAction(okAction)
    self.present(alertController, animated: true, completion: nil)
  }

  // If data in text fields isn't valid, give an alert
  func presentInvalidDataAlert(message: String) {
    Utils.showSimpleAlert(title: "Invalid Input", message: message, presentingVC: self)
  }

  func saveImage(photoData: Data) {
    let storageRef = Storage.storage().reference(withPath: restaurant.documentID)
    storageRef.putData(photoData, metadata: nil) { (metadata, error) in
      if let error = error {
        print(error)
        return
      }
      storageRef.downloadURL { (url, error) in
        if let error = error {
          print(error)
        }
        if let url = url {
          self.downloadUrl = url.absoluteString
        }
      }
    }
  }

  // MARK: Keyboard functionality

  @objc func inputToolbarDonePressed() {
    resignFirstResponder()
  }

  @objc func keyboardNextButton() {
    if cityTextField.isFirstResponder {
      categoryTextField.becomeFirstResponder()
    } else if categoryTextField.isFirstResponder {
      priceTextField.becomeFirstResponder()
    } else if restaurantNameTextField.isFirstResponder {
      cityTextField.becomeFirstResponder()
    } else {
      resignFirstResponder()
    }
  }

  @objc func keyboardPreviousButton() {
    if cityTextField.isFirstResponder {
      restaurantNameTextField.becomeFirstResponder()
    } else if categoryTextField.isFirstResponder {
      cityTextField.becomeFirstResponder()
    } else if priceTextField.isFirstResponder {
      categoryTextField.becomeFirstResponder()
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
    let trimmed = textField.text?.trimmingCharacters(in: .whitespaces)
    textField.text = trimmed
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
