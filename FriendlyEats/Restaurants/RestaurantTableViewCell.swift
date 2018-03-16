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
import UIKit


class RestaurantTableViewCell: UITableViewCell {

  @IBOutlet private var thumbnailView: UIImageView!

  @IBOutlet private var nameLabel: UILabel!

  @IBOutlet var starsView: ImmutableStarsView!

  @IBOutlet private var cityLabel: UILabel!

  @IBOutlet private var categoryLabel: UILabel!

  @IBOutlet private var priceLabel: UILabel!

  func populate(restaurant: Restaurant) {
    nameLabel.text = restaurant.name
    cityLabel.text = restaurant.city
    categoryLabel.text = restaurant.category
    starsView.rating = Int(restaurant.averageRating.rounded())
    priceLabel.text = Utils.priceString(from: restaurant.price)
    thumbnailView.sd_setImage(with: restaurant.photoURL)
  }

  override func prepareForReuse() {
    super.prepareForReuse()
    thumbnailView.sd_cancelCurrentImageLoad()
  }

}

