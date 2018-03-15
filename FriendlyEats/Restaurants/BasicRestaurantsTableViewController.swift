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

class BasicRestaurantsTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

  @IBOutlet var tableView: UITableView!
  // You can ignore these properties. They're used later on in the workshop.
  @IBOutlet var activeFiltersStackView: UIStackView!
  @IBOutlet var stackViewHeightConstraint: NSLayoutConstraint!
  @IBOutlet var cityFilterLabel: UILabel!
  @IBOutlet var categoryFilterLabel: UILabel!
  @IBOutlet var priceFilterLabel: UILabel!


  let backgroundView = UIImageView()
  var restaurantData: [Restaurant] = []
  var restaurantListener: ListenerRegistration?

  private func startListeningForRestaurants() {
    // TODO: Create a listener for the "restaurants" collection and use that data
    // to popualte our `restaurantData` model
  }

  func tryASampleQuery() {
    // TODO: Let's put a sample query here to see how basic data fetching works in
    // Cloud Firestore
  }

  private func stopListeningForRestaurants() {
    // TODO: We should "deactivate" our restaurant listener when this view goes away
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    backgroundView.image = UIImage(named: "pizza-monster")!
    backgroundView.contentMode = .scaleAspectFit
    backgroundView.alpha = 0.5
    tableView.backgroundView = backgroundView
    tableView.tableFooterView = UIView()
    stackViewHeightConstraint.constant = 0
    activeFiltersStackView.isHidden = true
    tableView.delegate = self
    tableView.dataSource = self
    tryASampleQuery()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    setNeedsStatusBarAppearanceUpdate()
    startListeningForRestaurants()
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    stopListeningForRestaurants()
  }

  // MARK: - Table view data source

  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return restaurantData.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "RestaurantTableViewCell",
                                             for: indexPath) as! RestaurantTableViewCell
    let restaurant = restaurantData[indexPath.row]
    cell.populate(restaurant: restaurant)
    return cell
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    let restaurant = restaurantData[indexPath.row]
    let controller = RestaurantDetailViewController.fromStoryboard(restaurant: restaurant)
    self.navigationController?.pushViewController(controller, animated: true)
  }

  @IBAction func didTapPopulateButton(_ sender: Any) {
    let confirmationBox = UIAlertController(title: "Populate the database",
                                            message: "This will add populate the database with several new restaurants and reviews. Would you like to proceed?",
                                            preferredStyle: .alert)
    confirmationBox.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    confirmationBox.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
      Firestore.firestore().prepopulate()
    }))
    present(confirmationBox, animated: true)
  }

}


