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

  private var restaurants: [Restaurant] = []

  // Pull data from Firestore

  /// Starts listening to the Firestore query and invoking the updateHandler.
  public func startUpdates() {
    fatalError("Unimplemented")
  }

  /// Stops listening to the Firestore query. updateHandler will not be called unless startListening
  /// is called again.
  public func stopUpdates() {
    fatalError("Unimplemented")
  }

  /// Returns the restaurant at the given index.
  subscript(index: Int) -> Restaurant {
    return restaurants[index]
  }

  /// The number of items in the data source.
  public var count: Int {
    return restaurants.count
  }

  // MARK: - UITableViewDataSource

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "RestaurantTableViewCell",
                                             for: indexPath) as! RestaurantTableViewCell
    let restaurant = restaurants[indexPath.row]
    cell.populate(restaurant: restaurant)
    return cell
  }

}

