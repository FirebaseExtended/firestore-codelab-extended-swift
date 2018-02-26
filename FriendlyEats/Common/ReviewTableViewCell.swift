//
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
import Firebase

class ReviewTableViewCell: UITableViewCell {

  @IBOutlet var usernameLabel: UILabel?
  @IBOutlet var reviewContentsLabel: UILabel!
  @IBOutlet var starsView: ImmutableStarsView!
  @IBOutlet weak var yumsLabel: UILabel!
  @IBOutlet weak var userIcon: UIImageView?
  @IBOutlet weak var yumButton: UIButton!
  @IBOutlet weak var restaurantNameLabel: UILabel?

  var review: Review!

  func populate(review: Review) {

  }

  @IBAction func yumWasTapped(_ sender: Any) {
    let reviewReference = Firestore.firestore().collection("reviews").document(review.documentID)
    Firestore.firestore().runTransaction({ (transaction, errorPointer) -> Any? in

      // First, we're going to make sure we have the most up-to-date number of yums
      let reviewSnapshot:DocumentSnapshot
      do {
        try reviewSnapshot = transaction.getDocument(reviewReference)
      } catch let error as NSError {
        errorPointer?.pointee = error
        return nil
      }

      // We can convert our snapshot to a review object
      guard let latestReview = Review(document: reviewSnapshot) else {
        let error = NSError(domain: "FriendlyEatsErrorDomain", code: 0, userInfo: [
          NSLocalizedDescriptionKey: "Review at \(reviewReference.path) didn't look like a valid review"
          ])
        errorPointer?.pointee = error
        return nil
      }

      guard let currentUser = Auth.auth().currentUser else {
        let error = NSError(domain: "FriendlyEatsErrorDomain", code: 0, userInfo: [
          NSLocalizedDescriptionKey: "You need to be signed in to Yum a review"
          ])
        errorPointer?.pointee = error
        return nil
      }

      // First we are going to write a simple "Yum" object into our subcollection...
      let newYum = Yum(documentID: currentUser.uid, username: currentUser.displayName ?? "Unknown user")
      let newYumReference = reviewReference.collection("yums").document(newYum.documentID)
      transaction.setData(newYum.documentData, forDocument: newYumReference)

      // Finally, we can update the "Yum" count
      let newYumCount = latestReview.yumCount + 1
      transaction.updateData(["yumCount": newYumCount], forDocument: reviewReference)

      return nil

    })  { (_, error) in
      if let error = error {
        print("Got an error attempting the transaction: \(error)")
      } else {
        print("Transaction successful!")
      }
    }

  }

}
