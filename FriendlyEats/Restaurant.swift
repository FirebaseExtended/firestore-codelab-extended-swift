//
//  Copyright (c) 2016 Google Inc.
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

/// A restaurant, created by a user.
struct Restaurant {

  /// The ID of the restaurant, generated using UUID.
  var restaurantID: String

  /// The restaurant owner's uid. Corresponds to a user object in the top-level Users collection.
  var ownerID: String

  /// The name of the restaurant.
  var name: String

  /// The category of the restaurant.
  var category: String

  /// The city the restaurant is located in.
  var city: String

  /// The price category of the restaurant. Values are clamped between 1 and 3 (inclusive).
  var price: Int

  /// The number of reviews that have been left for this restaurant.
  var reviewCount: Int

  /// The average rating of all the restaurant's reviews.
  var averageRating: Float

  /// The restaurant's photo URL.
  var photoURL: URL

  /// The dictionary representation of the restaurant for uploading to Firestore.
  var dictionary: [String: Any] {
    return [
      "restaurantID": restaurantID,
      "ownerID": ownerID,
      "name": name,
      "category": category,
      "city": city,
      "price": price,
      "reviewCount": reviewCount,
      "averageRating": averageRating,
      "photoURL": photoURL
    ]
  }

}

extension Restaurant: DocumentSerializable {

  // TODO(morganchen): For non-US audiences, we may want to localize these to non-US cities.
  // This is a smaller part of the larger codelab localization discussion.
  static let cities = [
    "Albuquerque",
    "Arlington",
    "Atlanta",
    "Austin",
    "Baltimore",
    "Boston",
    "Charlotte",
    "Chicago",
    "Cleveland",
    "Colorado Springs",
    "Columbus",
    "Dallas",
    "Denver",
    "Detroit",
    "El Paso",
    "Fort Worth",
    "Fresno",
    "Houston",
    "Indianapolis",
    "Jacksonville",
    "Kansas City",
    "Las Vegas",
    "Long Beach",
    "Los Angeles",
    "Louisville",
    "Memphis",
    "Mesa",
    "Miami",
    "Milwaukee",
    "Nashville",
    "New York",
    "Oakland",
    "Oklahoma",
    "Omaha",
    "Philadelphia",
    "Phoenix",
    "Portland",
    "Raleigh",
    "Sacramento",
    "San Antonio",
    "San Diego",
    "San Francisco",
    "San Jose",
    "Tucson",
    "Tulsa",
    "Virginia Beach",
    "Washington"
  ]

  static let categories = [
    "Brunch", "Burgers", "Coffee", "Deli", "Dim Sum", "Indian", "Italian",
    "Mediterranean", "Mexican", "Pizza", "Ramen", "Sushi"
  ]

  init?(dictionary: [String : Any]) {
    guard let restaurantID = dictionary["restaurantID"] as? String,
        let ownerID = dictionary["ownerID"] as? String,
        let name = dictionary["name"] as? String,
        let category = dictionary["category"] as? String,
        let city = dictionary["city"] as? String,
        let price = dictionary["price"] as? Int,
        let reviewCount = dictionary["reviewCount"] as? Int,
        let averageRating = dictionary["averageRating"] as? Float,
        let photoURLString = dictionary["photoURL"] as? String else { return nil }

    guard let photoURL = URL(string: photoURLString) else { return nil }

    self.init(restaurantID: restaurantID,
              ownerID: ownerID,
              name: name,
              category: category,
              city: city,
              price: price,
              reviewCount: reviewCount,
              averageRating: averageRating,
              photoURL: photoURL)
  }

}
