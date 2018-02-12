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
import SDWebImage
import FirebaseFirestore
import Firebase
import FirebaseAuthUI

class RestaurantDetailViewController: UIViewController {

  // These are optional because we can't do initializer-level dependency injection with storyboards.
  var titleImageURL: URL?
  var restaurant: Restaurant?  
  var localCollection: LocalCollection<Review>!
  var dataSource: ReviewTableViewDataSource!

  static func fromStoryboard(_ storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil))
      -> RestaurantDetailViewController {
    let controller =
        storyboard.instantiateViewController(withIdentifier: "RestaurantDetailViewController")
        as! RestaurantDetailViewController
    return controller
  }
  
  @IBOutlet var tableView: UITableView!
  @IBOutlet var titleView: RestaurantTitleView!
  @IBOutlet weak var editButton: UIButton!
  
  let backgroundView = UIImageView()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.title = restaurant?.name
    navigationController?.navigationBar.tintColor = UIColor.white
    
    backgroundView.image = UIImage(named: "pizza-monster")!
    backgroundView.contentScaleFactor = 2
    backgroundView.contentMode = .bottom
    tableView.backgroundView = backgroundView
    tableView.tableFooterView = UIView()
    
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 120

    // enable edit button if owner of restaurant
    editButton.isHidden = true
    if restaurant?.ownerID == FirebaseAuth.Auth.auth().currentUser?.uid {
      editButton.isHidden = false
    }

    let query = Firestore.firestore().reviews.whereField("restaurantID",
                                                         isEqualTo: restaurant!.documentID)
    localCollection = LocalCollection(query: query) { [unowned self] (changes) in
      if self.localCollection.count == 0 {
        self.tableView.backgroundView = self.backgroundView
        return
      } else {
        self.tableView.backgroundView = nil
      }
      var indexPaths: [IndexPath] = []
      
      // Only care about additions in this block, updating existing reviews probably not important
      // as there's no way to edit reviews.
      for addition in changes.filter({ $0.type == .added }) {
        let index = self.localCollection.index(of: addition.document)!
        let indexPath = IndexPath(row: index, section: 0)
        indexPaths.append(indexPath)
      }
      
      self.tableView.insertRows(at: indexPaths, with: .automatic)
    }

    dataSource = ReviewTableViewDataSource(reviews: localCollection)
    tableView.dataSource = dataSource
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 140
  }
  
  deinit {
    localCollection.stopListening()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    localCollection.listen()
    titleView.populate(restaurant: restaurant!)
    if let url = titleImageURL {
      titleView.populateImage(url: url)
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    set {}
    get {
      return .lightContent
    }
  }
  
  @IBAction func didTapAddButton(_ sender: Any) {
    let controller = NewReviewViewController.fromStoryboard(forRestaurant: self.restaurant!)
    self.navigationController?.pushViewController(controller, animated: true)
  }
  
  @IBAction func didTapEditButton(_ sender: Any) {
    let controller =
      EditRestaurantViewController.fromStoryboard()
    controller.restaurant = self.restaurant
    self.navigationController?.pushViewController(controller, animated: true)
  }

}

class RestaurantTitleView: UIView {
  
  @IBOutlet var nameLabel: UILabel!
  
  @IBOutlet var categoryLabel: UILabel!
  
  @IBOutlet var cityLabel: UILabel!
  
  @IBOutlet var priceLabel: UILabel!
  
  @IBOutlet var starsView: ImmutableStarsView! {
    didSet {
      starsView.highlightedColor = UIColor.white.cgColor
    }
  }
  
  @IBOutlet var titleImageView: UIImageView! {
    didSet {
      let gradient = CAGradientLayer()
      gradient.colors =
          [UIColor(red: 0, green: 0, blue: 0, alpha: 0.6).cgColor, UIColor.clear.cgColor]
      gradient.locations = [0.0, 1.0]
      
      gradient.startPoint = CGPoint(x: 0, y: 1)
      gradient.endPoint = CGPoint(x: 0, y: 0)
      gradient.frame = CGRect(x: 0,
                              y: 0,
                              width: UIScreen.main.bounds.width,
                              height: titleImageView.bounds.height)
      
      titleImageView.layer.insertSublayer(gradient, at: 0)
      titleImageView.contentMode = .scaleAspectFill
      titleImageView.clipsToBounds = true
    }
  }
  
  func populateImage(url: URL) {
    titleImageView.sd_setImage(with: url)
  }
  
  func populate(restaurant: Restaurant) {
    nameLabel.text = restaurant.name
    categoryLabel.text = restaurant.category
    cityLabel.text = restaurant.city
    priceLabel.text = priceString(from: restaurant.price)
    starsView.rating = Int(restaurant.averageRating.rounded())
    populateImage(url: restaurant.photoURL)
  }
  
}

class ReviewTableViewCell: UITableViewCell {
  
  @IBOutlet var usernameLabel: UILabel!
  @IBOutlet var reviewContentsLabel: UILabel!
  @IBOutlet var starsView: ImmutableStarsView!
  @IBOutlet weak var yumsLabel: UILabel!
  @IBOutlet weak var userIcon: UIImageView!
  @IBOutlet weak var yumButton: UIButton!

  var review: Review!

  func populate(review: Review) {
    self.review = review
    usernameLabel.text = review.userInfo.name
    userIcon.sd_setImage(with: review.userInfo.photoURL)
    starsView.rating = review.rating
    reviewContentsLabel.text = review.text
    switch review.yumCount {
    case 0:
      yumsLabel.isHidden = true
      break
    case 1:
      yumsLabel.isHidden = false
      yumsLabel.text = "1 yum"
      break
    default:
      yumsLabel.isHidden = false
      yumsLabel.text = "\(review.yumCount) yums"
    }
  }

  @IBAction func yumWasTapped(_ sender: Any) {
    print("Yum was tapped!!")
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
