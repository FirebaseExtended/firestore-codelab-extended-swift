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

class HackPageViewController: UIViewController {
  @IBOutlet weak var editReviewStatus: UILabel!
  @IBOutlet weak var changeRestNameStatus: UILabel!
  @IBOutlet weak var changeUserPicStatus: UILabel!
  @IBOutlet weak var addFakeReviewStatus: UILabel!

  static func fromStoryboard(_ storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)) -> HackPageViewController {
    let controller = storyboard.instantiateViewController(withIdentifier: "HackPageViewController") as! HackPageViewController
    return controller
  }

  @IBAction func editReviewWasTapped(_ sender: Any) {
    Firestore.firestore().collection("reviews").limit(to: 20).getDocuments { (snapshotBlock, error) in
      if let error = error {
        print("Received fetch error \(error)")
        self.editReviewStatus.text = "Fetch error"
        return
      }
      guard let documents = snapshotBlock?.documents else { return }
      let currentUserID = Auth.auth().currentUser?.uid

      // Let's find a review that we didn't write
      for reviewDoc in documents {
        guard let review = Review(document: reviewDoc) else { continue }
        if review.userInfo.userID != currentUserID {
          self.hackReview(review)
          // We only want to hack one review
          break
        }
      }
    }
  }

  func hackReview(_ review: Review) {
    var hackedReview = review
    hackedReview.rating = 1
    hackedReview.text = "YOU HAVE BEEN HACKED!!!11!"
    hackedReview.yumCount = 99
    hackedReview.userInfo.name = "ANONYMOUS"
    let documentRef = Firestore.firestore().collection("reviews").document(hackedReview.documentID)
    documentRef.updateData(hackedReview.documentData) { (error) in
      if let error = error {
        print("Could not update review: \(error)")
        self.editReviewStatus.text = "Hack failed!"
      } else {
        self.editReviewStatus.text = "Mischief Managed"
      }
    }
  }


  @IBAction func changeRestNameWasTapped(_ sender: Any) {
  }

  @IBAction func changeUserPicWasTapped(_ sender: Any) {
  }

  @IBAction func addFakeReviewWasTapped(_ sender: Any) {
  }

  override func viewDidLoad() {
    super.viewDidLoad()
  }


}
