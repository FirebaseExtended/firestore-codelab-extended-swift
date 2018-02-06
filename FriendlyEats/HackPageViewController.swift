//
//  HackPageViewController.swift
//  FriendlyEats
//
//  Created by Todd Kerpelman on 2/6/18.
//  Copyright © 2018 Firebase. All rights reserved.
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
    documentRef.updateData(hackedReview.documentData, completion: { (error) in
      if let error = error {
        print("Could not update review: \(error)")
        self.editReviewStatus.text = "Hack failed!"
      } else {
        self.editReviewStatus.text = "Mischief Managed"
      }
    })
  }


  @IBAction func changeRestNameWasTapped(_ sender: Any) {
  }

  @IBAction func changeUserPicWasTapped(_ sender: Any) {
  }

  @IBAction func addFakeReviewWasTapped(_ sender: Any) {
  }

  override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }


}
