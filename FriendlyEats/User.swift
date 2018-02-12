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

import FirebaseFirestore
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

  /// All users are stored by their userIDs for easier querying later.
  var documentID: String {
    return userID
  }

  /// The default URL for profile images.
  static let defaultPhotoURL =
      URL(string: "https://storage.googleapis.com/firestorequickstarts.appspot.com/food_1.png")!

  /// Initializes a User from document snapshot data.
  private init?(documentID: String, dictionary: [String : Any]) {
    guard let userID = dictionary["userID"] as? String else { return nil }

    // This is something that should be verified on the server using a security rule.
    // In order to maintain a consistent database, all users must be stored in the top-level
    // users collection by their userID. Some queries are dependent on this consistency.
    precondition(userID == documentID)

    self.init(dictionary: dictionary)
  }

  /// A convenience initializer for user data that won't be written to the Users collection
  /// in Firestore. Unlike the other data types, users aren't dependent on Firestore to
  /// generate unique identifiers, since they come with unique identifiers for free.
  public init?(dictionary: [String: Any]) {
    guard let name = dictionary["name"] as? String,
      let userID = dictionary["userID"] as? String,
      let photoURLString = dictionary["photoURL"] as? String else { return nil }
    guard let photoURL = URL(string: photoURLString) else { return nil }

    self.init(userID: userID, name: name, photoURL: photoURL)
  }

  public init?(document: QueryDocumentSnapshot) {
    self.init(documentID: document.documentID, dictionary: document.data())
  }

  public init?(document: DocumentSnapshot) {
    guard let data = document.data() else { return nil }
    self.init(documentID: document.documentID, dictionary: data)
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
  public var documentData: [String: Any] {
    return [
      "userID": userID,
      "name": name,
      "photoURL": photoURL.absoluteString
    ]
  }

}

// MARK: - Data generation


/// A helper for user generation.
extension User {

  static let firstNames = ["Sophia", "Jackson", "Olivia", "Liam", "Emma", "Noah", "Ava", "Aiden",
                            "Isabella", "Lucas", "Mia", "Caden", "Aria", "Grayson", "Riley", "Mason"]

  static let lastNames = ["Smith", "Johnson", "Williams", "Jones", "Brown", "Davis", "Miller", "Wilson",
                          "Moore", "Taylor", "Anderson", "Thomas", "Jackson", "White", "Harris", "Martin",
                          "Thompson", "Garcia", "Martinez", "Robinson", "Clark", "Rodriguez", "Lewis", "Lee"]

  static func randomUsername() -> String {
    let randomIndexes = (RandomUniform(firstNames.count), RandomUniform(lastNames.count))
    return firstNames[randomIndexes.0] + " " + lastNames[randomIndexes.1]
  }
  
}
