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
  var averageRating: Double

  /// The restaurant's photo URL. These are stored as strings in Firestore.
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
      "photoURL": photoURL.absoluteString
    ]
  }

}

extension Restaurant: DocumentSerializable {

  init?(dictionary: [String : Any]) {
    guard let restaurantID = dictionary["restaurantID"] as? String,
        let ownerID = dictionary["ownerID"] as? String,
        let name = dictionary["name"] as? String,
        let category = dictionary["category"] as? String,
        let city = dictionary["city"] as? String,
        let price = dictionary["price"] as? Int,
        let reviewCount = dictionary["reviewCount"] as? Int,
        let averageRating = dictionary["averageRating"] as? Double,
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

/// A wrapper of arc4random_uniform, to avoid lots of casting.
func RandomUniform(_ upperBound: Int) -> Int {
  return Int(arc4random_uniform(UInt32(upperBound)))
}

/// A helper for restaurant generation.
extension Restaurant {

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

  static func randomName() -> String {
    let words = ["Bar", "Fire", "Grill", "Drive Thru", "Place", "Best", "Spot", "Prime", "Eatin'"]
    let randomIndexes = (RandomUniform(words.count), RandomUniform(words.count))
    return words[randomIndexes.0] + " " + words[randomIndexes.1]
  }

  static func randomCategory() -> String {
    return Restaurant.categories[RandomUniform(Restaurant.categories.count)]
  }

  static func randomCity() -> String {
    return Restaurant.cities[RandomUniform(Restaurant.cities.count)]
  }

  static func randomPrice() -> Int {
    return RandomUniform(3) + 1
  }

  static func randomPhotoURL() -> URL {
    let number = RandomUniform(22) + 1
    let URLString =
        "https://storage.googleapis.com/firestorequickstarts.appspot.com/food_\(number).png"
    return URL(string: URLString)!
  }

}
