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

class RestaurantDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NewReviewViewControllerDelegate {

  // These are optional because we can't do initializer-level dependency injection with storyboards.
  var titleImageURL: URL?
  var restaurant: Restaurant?  
  var localCollection: LocalCollection<Review>!
  
  static func fromStoryboard(_ storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)) -> RestaurantDetailViewController {
    let controller = storyboard.instantiateViewController(withIdentifier: "RestaurantDetailViewController") as! RestaurantDetailViewController
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
    
    tableView.dataSource = self
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 140
    
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
    let controller = NewReviewViewController.fromStoryboard()
    controller.delegate = self
    self.navigationController?.pushViewController(controller, animated: true)
  }
  
  @IBAction func didTapEditButton(_ sender: Any) {
    let controller =
      EditRestaurantViewController.fromStoryboard()
    controller.restaurant = self.restaurant
    self.navigationController?.pushViewController(controller, animated: true)
  }
  
  
  // MARK: - UITableViewDataSource
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return localCollection.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewTableViewCell",
                                             for: indexPath) as! ReviewTableViewCell
    let review = localCollection[indexPath.row]
    cell.populate(review: review)
    return cell
  }
  
  // MARK: - NewReviewViewControllerDelegate
  
  func reviewController(_ controller: NewReviewViewController, didSubmitFormWithReview review: Review) {
    // TODO: write transaction logic for creating new review.
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
      gradient.colors = [UIColor(red: 0, green: 0, blue: 0, alpha: 0.6).cgColor, UIColor.clear.cgColor]
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
  
  func populate(review: Review) {
    usernameLabel.text = review.userInfo.name
    starsView.rating = review.rating
    reviewContentsLabel.text = review.text
  }
  
}
