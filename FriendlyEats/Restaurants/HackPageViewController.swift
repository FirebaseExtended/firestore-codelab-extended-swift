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
  @IBOutlet weak var addBadDataStatus: UILabel!
  @IBOutlet weak var giveMeFiveStarsStatus: UILabel!

  let currentUserID = Auth.auth().currentUser?.uid


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

      // Let's find a review that we didn't write
      for reviewDoc in documents {
        guard let review = Review(document: reviewDoc) else { continue }
        if review.userInfo.userID != self.currentUserID {
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
    Firestore.firestore().collection("restaurants").limit(to: 20).getDocuments { (snapshotBlock, error) in
      if let error = error {
        print("Received fetch error \(error)")
        self.changeRestNameStatus.text = "Fetch error"
        return
      }
      guard let documents = snapshotBlock?.documents else { return }

      // Let's find a restaurant that we don't own
      for restaurantDoc in documents {
        guard let restaurant = Restaurant(document: restaurantDoc) else { continue }
        if restaurant.ownerID != self.currentUserID {
          self.hackOthersRestaurant(restaurant)
          // We only want to hack one restaurant
          break
        }
      }
    }
  }

  func hackOthersRestaurant(_ restaurant: Restaurant) {
    var hackedRestaurant = restaurant
    hackedRestaurant.name = "DON'T EAT HERE"
    hackedRestaurant.category = "GARBAGE"
    hackedRestaurant.city = "HACKEDVILLE"
    hackedRestaurant.averageRating = 1
    hackedRestaurant.photoURL = URL(string: "https://storage.googleapis.com/firestorequickstarts.appspot.com/food_garbage.png")!
    let documentRef = Firestore.firestore().collection("restaurants").document(hackedRestaurant.documentID)
    documentRef.updateData(hackedRestaurant.documentData) { (error) in
      if let error = error {
        print("Could not update restaurant: \(error)")
        self.changeRestNameStatus.text = "Hack failed!"
      } else {
        self.changeRestNameStatus.text = "Mischief Managed"
      }
    }
  }

  @IBAction func addInvalidResturantData(_ sender: Any) {
    let badRestaurantData: [String : Any] = ["averageRating": "Good",
                                             "category": "Sushi",
                                             "city": 42.3,
                                             "name": "a",
                                             "ownerID": currentUserID!,
                                             "photoURL": "https://storage.googleapis.com/firestorequickstarts.appspot.com/food_3.png",
                                             "price": "expensive",
                                             "reviewCount": -3]
    Firestore.firestore().collection("restaurants").document("zzzzzzz-BADDATA").setData(badRestaurantData) { (error) in
      if let error = error {
        print("Could not update restaurant: \(error)")
        self.addBadDataStatus.text = "Hack failed!"
      } else {
        self.addBadDataStatus.text = "Mischief Managed"
      }
    }

  }


  @IBAction func changeUserPicWasTapped(_ sender: Any) {
    Firestore.firestore().collection("users").limit(to: 20).getDocuments { (snapshotBlock, error) in
      if let error = error {
        print("Received fetch error \(error)")
        self.changeUserPicStatus.text = "Fetch error"
        return
      }
      guard let documents = snapshotBlock?.documents else { return }
      // Let's find a user that isn't the current user
      for userDoc in documents {
        guard let user = User(document: userDoc) else { continue }
        if user.userID != self.currentUserID {
          self.hackOtherUser(user)
          // We only want to hack one restaurant
          break
        }
      }
    }
  }

  func hackOtherUser(_ user: User) {
    var hackedUser = user
    hackedUser.name = "JOHNNY MNEMONIC"
    hackedUser.photoURL = URL(string: "https://storage.googleapis.com/firestorequickstarts.appspot.com/user_hacker.png")!
    let documentRef = Firestore.firestore().collection("users").document(hackedUser.documentID)
    documentRef.updateData(hackedUser.documentData) { (error) in
      if let error = error {
        print("Could not update user: \(error)")
        self.changeUserPicStatus.text = "Hack failed!"
      } else {
        self.changeUserPicStatus.text = "Mischief Managed"
      }
    }
  }


  @IBAction func addFakeReviewWasTapped(_ sender: Any) {
    let myRestaurantQuery = Firestore.firestore().collection("restaurants").limit(to: 3)
    myRestaurantQuery.getDocuments { (snapshotBlock, error) in
      if let error = error {
        print("Received fetch error \(error)")
        self.addFakeReviewStatus.text = "Fetch error"
        return
      }
      guard let documents = snapshotBlock?.documents else { return }
      // Let's find a restaurant that we don't own
      for restaurantDoc in documents {
        guard let restaurant = Restaurant(document: restaurantDoc) else { continue }
        self.writeFakeReviewFor(restaurant)
      }
    }
  }

  func writeFakeReviewFor(_ restaurant: Restaurant) {
    let fakeUser = User(userID: "ABCDEFG",
                        name: "Jane Fake",
                        photoURL: URL(string: "https://storage.googleapis.com/firestorequickstarts.appspot.com/user_fake.png")!)
    let fakeReview = Review(restaurantID: restaurant.documentID,
                            restaurantName: restaurant.name,
                            rating: 5,
                            userInfo: fakeUser,
                            text: "This place is great! And I'm totally not making this up because I'm a fake person!",
                            date: Date(),
                            yumCount: 80)
    Firestore.firestore().collection("reviews").addDocument(data: fakeReview.documentData) { (error) in
      if let error = error {
        print("Could not update user: \(error)")
        self.addFakeReviewStatus.text = "Hack failed!"
      } else {
        self.addFakeReviewStatus.text = "Mischief Managed"
      }
    }
  }

  @IBAction func giveMeFiveStarsWasTapped(_ sender: Any) {
    let myRestaurantQuery = Firestore.firestore().collection("restaurants").whereField("ownerID", isEqualTo: currentUserID!).limit(to: 1)
    myRestaurantQuery.getDocuments { (snapshotBlock, error) in
      if let error = error {
        print("Received fetch error \(error)")
        self.giveMeFiveStarsStatus.text = "Fetch error"
        return
      }
      guard let documents = snapshotBlock?.documents else { return }
      for restaurantDoc in documents {
        guard let restaurant = Restaurant(document: restaurantDoc) else { continue }
        self.giveFiveStarsTo(restaurant)
      }
    }
  }

  func giveFiveStarsTo(_ restaurant: Restaurant) {
    let newData = ["averageRating": 5, "reviewCount": 100]
    Firestore.firestore().collection("restaurants").document(restaurant.documentID).updateData(newData) { (error) in
      if let error = error {
        print("Could not update restuarant: \(error)")
        self.giveMeFiveStarsStatus.text = "Hack failed!"
      } else {
        self.giveMeFiveStarsStatus.text = "Mischief Managed"
      }
    }
  }


  override func viewDidLoad() {
    super.viewDidLoad()
  }

}
