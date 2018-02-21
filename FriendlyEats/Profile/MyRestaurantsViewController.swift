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
import FirebaseAuth
import FirebaseFirestore

class MyRestaurantsViewController: UIViewController {

  static func fromStoryboard(_ storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil))
    -> MyRestaurantsViewController {
      return storyboard.instantiateViewController(withIdentifier: "MyRestaurantsViewController")
          as! MyRestaurantsViewController
  }

  private var user: User!
  fileprivate var dataSource: RestaurantTableViewDataSource!

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    // These should all be nonnull. The user can be signed out by an event
    // outside of the app, like a password change, but we're ignoring that case
    // for simplicity. In a real-world app, you should dismiss this view controller
    // or present a login flow if the user is unexpectedly nil.
    user = User(user: Auth.auth().currentUser!)
    let query = Firestore.firestore().restaurants.whereField("ownerID", isEqualTo: user.userID)
    dataSource = RestaurantTableViewDataSource(query: query) { (changes) in
      self.tableView.reloadData()
    }

    tableView.dataSource = dataSource
    dataSource.startUpdates()
    tableView.delegate = self
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    dataSource.stopUpdates()
  }

  @IBOutlet private var tableView: UITableView!

  @IBAction private func didTapAddRestaurantButton(_ sender: Any) {
    let controller = AddRestaurantViewController.fromStoryboard()
    self.navigationController?.pushViewController(controller, animated: true)
  }

}

// MARK: - UITableViewDelegate

extension MyRestaurantsViewController: UITableViewDelegate {

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    let restaurant = dataSource[indexPath.row]
    let controller = RestaurantDetailViewController.fromStoryboard(restaurant: restaurant)
    self.navigationController?.pushViewController(controller, animated: true)
  }
}
