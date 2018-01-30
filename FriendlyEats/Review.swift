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

import Foundation

/// A review of a restaurant, created by a user.
struct Review {

  /// A unique ID identifying the review, generated using UUID.
  var reviewID: String

  /// The restaurant that this review is reviewing.
  var restaurantID: String

  /// The rating given to the restaurant. Values range between 1 and 5.
  var rating: Int

  /// User information duplicated in the review object.
  var userInfo: User

  /// The body text of the review, containing the user's comments.
  var text: String

  /// The date the review was posted.
  var date: Date

  /// The number of yums (likes) that the review has received.
  var yumCount: Int

  /// A review's representation in Firestore.
  var dictionary: [String: Any] {
    return [
      "reviewID": reviewID,
      "restaurantID": restaurantID,
      "rating": rating,
      "userInfo": userInfo.dictionary,
      "text": text,
      "date": date,
      "yumCount": yumCount
    ]
  }

}

extension Review: DocumentSerializable {

  /// Initializes a review from a dictionary. Returns nil if any fields are missing, or if
  /// the User object is not serializable.
  init?(dictionary: [String : Any]) {
    guard let reviewID = dictionary["reviewID"] as? String,
        let restaurantID = dictionary["restaurantID"] as? String,
        let rating = dictionary["rating"] as? Int,
        let userInfo = dictionary["userInfo"] as? [String: Any],
        let text = dictionary["text"] as? String,
        let date = dictionary["date"] as? Date,
        let yumCount = dictionary["yumCount"] as? Int else { return nil }

    guard let user = User(dictionary: userInfo) else { return nil }
    self.init(reviewID: reviewID,
              restaurantID: restaurantID,
              rating: rating,
              userInfo: user,
              text: text,
              date: date,
              yumCount: yumCount)
  }

}
