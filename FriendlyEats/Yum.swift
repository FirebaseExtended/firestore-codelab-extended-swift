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

/// A struct corresponding to a 'like' on social media.
struct Yum {

  /// The user that created the yum/like.
  var userID: String

  /// The review that was yum'd/liked.
  var reviewID: String

}

extension Yum: DocumentSerializable {

  /// Initializes a Yum from a Firestore document or dictionary.
  public init?(dictionary: [String : Any]) {
    guard let userID = dictionary["userID"] as? String,
      let reviewID = dictionary["reviewID"] as? String else { return nil }

    self.init(userID: userID, reviewID: reviewID)
  }

  /// Returns a dictionary representation of a Yum.
  public var dictionary: [String: Any] {
    return [
      "userID": userID,
      "reviewID": reviewID,
    ]
  }

}
