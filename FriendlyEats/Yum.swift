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

/// A struct corresponding to a 'like' on social media.
struct Yum {

  /// The documentID of the yum.
  var documentID: String

  /// The user that created the yum/like.
  var userID: String

  /// The review that was yum'd/liked.
  var reviewID: String

}

// MARK: - Firestore interoperability

extension Yum: DocumentSerializable {

  public init(userID: String, reviewID: String) {
    let document = Firestore.firestore().yums.document()
    self.init(documentID: document.documentID, userID: userID, reviewID: reviewID)
  }

  /// Initializes a Yum from Firestore document data.
  public init?(documentID: String, dictionary: [String : Any]) {
    guard let userID = dictionary["userID"] as? String,
      let reviewID = dictionary["reviewID"] as? String else { return nil }

    self.init(documentID: documentID, userID: userID, reviewID: reviewID)
  }

  public init?(document: DocumentSnapshot) {
    guard let data = document.data() else { return nil }
    self.init(documentID: document.documentID, dictionary: data)
  }

  public init?(document: QueryDocumentSnapshot) {
    self.init(documentID: document.documentID, dictionary: document.data())
  }

  /// Returns a dictionary representation of a Yum.
  public var documentData: [String: Any] {
    return [
      "userID": userID,
      "reviewID": reviewID,
    ]
  }

}
