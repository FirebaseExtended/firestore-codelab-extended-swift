//
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
import FirebaseFirestore
import FirebaseAuth

class NewReviewViewController: UIViewController, UITextFieldDelegate {

  static func fromStoryboard(_ storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil),
                             forRestaurant restaurant: Restaurant) -> NewReviewViewController {
    let controller = storyboard.instantiateViewController(withIdentifier: "NewReviewViewController") as! NewReviewViewController
    controller.restaurant = restaurant
    return controller
  }

  /// The restaurant being reviewed. This must be set when the controller is created.
  private var restaurant: Restaurant!

  @IBOutlet var doneButton: UIBarButtonItem!

  @IBOutlet var ratingView: RatingView! {
    didSet {
      ratingView.addTarget(self, action: #selector(ratingDidChange(_:)), for: .valueChanged)
    }
  }

  @IBOutlet var reviewTextField: UITextField! {
    didSet {
      reviewTextField.addTarget(self, action: #selector(textFieldTextDidChange(_:)), for: .editingChanged)
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    doneButton.isEnabled = false
    reviewTextField.delegate = self
  }

  @IBAction func cancelButtonPressed(_ sender: Any) {
    self.navigationController?.popViewController(animated: true)
  }

  @IBAction func doneButtonPressed(_ sender: Any) {
    // TODO: handle user not logged in.
    guard let user = Auth.auth().currentUser.flatMap(User.init) else { return }
    let review = Review(restaurantID: restaurant.documentID,
                        restaurantName: restaurant.name,
                        rating: ratingView.rating!,
                        userInfo: user,
                        text: reviewTextField.text!,
                        date: Date(),
                        yumCount: 0)

    // Write the review to Firestore. Average ratings on the restaurant document
    // being reviewed will be updated by a Cloud function.
    Firestore.firestore().reviews.document(review.documentID)
        .setData(review.documentData) { (error) in
          if let error = error {
            print(error)
          } else {
            // Pop the review controller on success
            if self.navigationController?.topViewController?.isKind(of: NewReviewViewController.self) ?? false {
              self.navigationController?.popViewController(animated: true)
            }
          }
    }
  }

  @objc func ratingDidChange(_ sender: Any) {
    updateSubmitButton()
  }

  func textFieldIsEmpty() -> Bool {
    guard let text = reviewTextField.text else { return true }
    return text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
  }

  func updateSubmitButton() {
    doneButton.isEnabled = (ratingView.rating != nil && !textFieldIsEmpty())
  }

  @objc func textFieldTextDidChange(_ sender: Any) {
    updateSubmitButton()
  }

}
