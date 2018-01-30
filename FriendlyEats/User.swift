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
import FirebaseAuth

/// A user corresponding to a Firebase user. Additional metadata for each user is stored in
/// Firestore.
struct User {

  /// The ID of the user. This corresponds with a Firebase user's uid property.
  var userID: String

  /// The display name of the user. Users with unspecified display names are given a default name.
  var name: String

  /// A url to the user's profile photo. Users with unspecified profile pictures are given a
  /// default profile picture.
  var photoURL: URL

}

extension User: DocumentSerializable {

  /// The default URL for profile images. This is a local URL, not a URL hosted on the web.
  static let defaultPhotoURL =
      URL(string: "https://storage.googleapis.com/firestorequickstarts.appspot.com/food_1.png")!

  /// Initializes a User from a dictionary.
  public init?(dictionary: [String : Any]) {
    guard let name = dictionary["name"] as? String,
        let userID = dictionary["userID"] as? String,
        let photoURLString = dictionary["photoURL"] as? String else { return nil }
    guard let photoURL = URL(string: photoURLString) else { return nil }
    self.init(userID: userID, name: name, photoURL: photoURL)
  }

  /// Initializes a new User from a Firebase user object.
  public init(user: FirebaseAuth.UserInfo) {
    self.init(userID: user.uid,
              name: user.displayName,
              photoURL: user.photoURL)
  }

  /// Returns a new User, providing a default name and photoURL if passed nil or left unspecified.
  public init(userID: String,
              name: String? = "FriendlyEats User",
              photoURL: URL? = User.defaultPhotoURL) {
    self.init(userID: userID,
              name: name ?? "FriendlyEats User",
              photoURL: photoURL ?? User.defaultPhotoURL)
  }

  /// Returns a randomly-generated User without checking for uid collisions, with the default name
  /// and profile picture.
  public init() {
    let uid = UUID().uuidString
    self.init(userID: uid)
  }

  /// A user object's representation in Firestore.
  public var dictionary: [String: Any] {
    return [
      "userID": userID,
      "name": name,
      "photoURL": photoURL.absoluteString
    ]
  }

}
