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

/// A class that populates a table view using ReviewTableViewCell cells
/// with review data from a Firestore query. Consumers should update the
/// table view with new data from Firestore in the updateHandler closure.
@objc class ReviewTableViewDataSource: NSObject, UITableViewDataSource {

  private let reviews: LocalCollection<Review>
  var sectionTitle: String?

  /// Returns an instance of ReviewTableViewDataSource. Consumers should update the
  /// table view with new data from Firestore in the updateHandler closure.
  public init(reviews: LocalCollection<Review>) {
    self.reviews = reviews
  }

  /// Returns an instance of ReviewTableViewDataSource. Consumers should update the
  /// table view with new data from Firestore in the updateHandler closure.
  public convenience init(query: Query, updateHandler: @escaping ([DocumentChange]) -> ()) {
    let collection = LocalCollection<Review>(query: query, updateHandler: updateHandler)
    self.init(reviews: collection)
  }

  /// Starts listening to the Firestore query and invoking the updateHandler.
  public func startUpdates() {
    reviews.listen()
  }

  /// Stops listening to the Firestore query. updateHandler will not be called unless startListening
  /// is called again.
  public func stopUpdates() {
    reviews.stopListening()
  }


  /// Returns the review at the given index.
  subscript(index: Int) -> Review {
    return reviews[index]
  }

  /// The number of items in the data source.
  public var count: Int {
    return reviews.count
  }

  // MARK: - UITableViewDataSource
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return sectionTitle
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewTableViewCell",
                                             for: indexPath) as! ReviewTableViewCell
    let review = reviews[indexPath.row]
    cell.populate(review: review)
    return cell
  }

}
