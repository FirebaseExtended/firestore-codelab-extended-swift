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

  let reviews: LocalCollection<Review>
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

  // MARK: - UITableViewDataSource
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return sectionTitle
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return reviews.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewTableViewCell",
                                             for: indexPath) as! ReviewTableViewCell
    let review = reviews[indexPath.row]
    cell.populate(review: review)
    return cell
  }

}
