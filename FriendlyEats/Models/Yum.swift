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

  /// The document ID for this particular yum. This will serve double-duty as
  /// the userID of the user who left the review as well, which will help guarantee
  /// only one yum per user per review.
  var documentID: String

  /// The name of the user who yummed this review. Although this is out of the
  /// scope of this sample app, this could be used to build a "This review was yummed by
  /// Bob Smith, Alex Avery, and 3 others" kind of message
  var username: String


}

// MARK: - Firestore interoperability

extension Yum: DocumentSerializable {

  /// Initializes a Yum from Firestore document data.
  public init?(documentAndUserID: String, dictionary: [String : Any]) {
    guard let username = dictionary["username"] as? String else { return nil }
    self.init(documentID: documentAndUserID,  username: username)
  }

  public init?(document: DocumentSnapshot) {
    guard let data = document.data() else { return nil }
    self.init(documentAndUserID: document.documentID, dictionary: data)
  }

  public init?(document: QueryDocumentSnapshot) {
    self.init(documentAndUserID: document.documentID, dictionary: document.data())
  }

  /// Returns a dictionary representation of a Yum.
  public var documentData: [String: Any] {
    return [
      "username": username,
    ]
  }

}
