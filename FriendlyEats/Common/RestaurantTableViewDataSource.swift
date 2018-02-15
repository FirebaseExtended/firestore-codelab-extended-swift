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
import FirebaseFirestore

/// A class that populates a table view using RestaurantTableViewCell cells
/// with restaurant data from a Firestore query. Consumers should update the
/// table view with new data from Firestore in the updateHandler closure.
@objc class RestaurantTableViewDataSource: NSObject, UITableViewDataSource {

  let restaurants: LocalCollection<Restaurant>

  /// Returns an instance of RestaurantTableViewDataSource. Consumers should update the
  /// table view with new data from Firestore in the updateHandler closure.
  public init(restaurants: LocalCollection<Restaurant>) {
    self.restaurants = restaurants
  }

  /// Returns an instance of RestaurantTableViewDataSource. Consumers should update the
  /// table view with new data from Firestore in the updateHandler closure.
  public convenience init(query: Query, updateHandler: @escaping ([DocumentChange]) -> ()) {
    let collection = LocalCollection<Restaurant>(query: query, updateHandler: updateHandler)
    self.init(restaurants: collection)
  }

  // MARK: - UITableViewDataSource

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return restaurants.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "RestaurantTableViewCell",
                                             for: indexPath) as! RestaurantTableViewCell
    let restaurant = restaurants[indexPath.row]
    cell.populate(restaurant: restaurant)
    return cell
  }

}

