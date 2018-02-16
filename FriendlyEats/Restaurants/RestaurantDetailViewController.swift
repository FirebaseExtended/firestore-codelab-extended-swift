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

class RestaurantDetailViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

  // These are optional because we can't do initializer-level dependency injection with storyboards.

  private var restaurant: Restaurant!
  private var localCollection: LocalCollection<Review>!
  private var dataSource: ReviewTableViewDataSource?

  private var query: Query? {
    didSet {
      if let query = query {
        localCollection = LocalCollection(query: query) { [unowned self] (changes) in
          print(changes)
          print(self.localCollection.items)
          if self.localCollection.count == 0 {
            self.tableView.backgroundView = self.backgroundView
          } else {
            self.tableView.backgroundView = nil
          }
          self.tableView.reloadData()
        }

        dataSource = ReviewTableViewDataSource(reviews: localCollection)
        localCollection.listen()
        tableView.dataSource = dataSource
      } else {
        localCollection.stopListening()
        dataSource = nil
        tableView.dataSource = nil
      }
    }
  }

  lazy private var baseQuery: Query = {
    Firestore.firestore().reviews
        .whereField("restaurantID", isEqualTo: restaurant.documentID)
  }()

  static func fromStoryboard(_ storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil),
                             restaurant: Restaurant) -> RestaurantDetailViewController {
    let controller =
        storyboard.instantiateViewController(withIdentifier: "RestaurantDetailViewController")
        as! RestaurantDetailViewController
    controller.restaurant = restaurant
    return controller
  }
  
  @IBOutlet var tableView: UITableView!
  @IBOutlet var titleView: RestaurantTitleView!
  @IBOutlet weak var editButton: UIButton!
  @IBOutlet weak var pickerView: UIPickerView!
  @IBOutlet weak var sortButton: UIButton!

  let backgroundView = UIImageView()
  let sortByOptions = ["date", "rating", "yumCount"]

  override func viewDidLoad() {
    super.viewDidLoad()

    //hide picker view on view load
    pickerView.isHidden = true
    pickerView.delegate = self
    pickerView.dataSource = self
    
    self.title = restaurant.name

    backgroundView.image = UIImage(named: "pizza-monster")!
    backgroundView.contentScaleFactor = 2
    backgroundView.contentMode = .bottom
    tableView.backgroundView = backgroundView
    tableView.tableFooterView = UIView()
    
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 120

    // enable edit button if owner of restaurant
    editButton.isHidden = true
    if restaurant.ownerID == FirebaseAuth.Auth.auth().currentUser?.uid {
      editButton.isHidden = false
    }

    // Sort by date by default.
    query = baseQuery.order(by: "date")
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
    titleView.populate(restaurant: restaurant)
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
      EditRestaurantViewController.fromStoryboard(restaurant: restaurant)
    self.navigationController?.pushViewController(controller, animated: true)
  }

  @IBAction func sortPressed(_ sender: Any) {
    if pickerView.isHidden {
      pickerView.isHidden = false
    }
  }

  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }

  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return sortByOptions.count
  }

  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return sortByOptions[row]
  }

  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    // pickerView.isHidden = true
    let sort = sortByOptions[row]
    print("Sorting by: \(sort)")
    query = baseQuery.order(by: sort)
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
  
  func populate(restaurant: Restaurant) {
    nameLabel.text = restaurant.name
    categoryLabel.text = restaurant.category
    cityLabel.text = restaurant.city
    priceLabel.text = priceString(from: restaurant.price)
    starsView.rating = Int(restaurant.averageRating.rounded())
    titleImageView.sd_setImage(with: restaurant.photoURL)
  }
  
}

