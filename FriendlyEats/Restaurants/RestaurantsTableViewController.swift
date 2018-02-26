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
import Firebase
import SDWebImage


class RestaurantsTableViewController: UIViewController, UITableViewDelegate {

  @IBOutlet var tableView: UITableView!
  @IBOutlet var activeFiltersStackView: UIStackView!
  @IBOutlet var stackViewHeightConstraint: NSLayoutConstraint!

  @IBOutlet var cityFilterLabel: UILabel!
  @IBOutlet var categoryFilterLabel: UILabel!
  @IBOutlet var priceFilterLabel: UILabel!

  let backgroundView = UIImageView()

  lazy private var dataSource: RestaurantTableViewDataSource = {
    return dataSourceForQuery(baseQuery)
  }()

  fileprivate var query: Query? {
    didSet {
      dataSource.stopUpdates()
      tableView.dataSource = nil
      if let query = query {
        dataSource = dataSourceForQuery(query)
        tableView.dataSource = dataSource
        dataSource.startUpdates()
      }
    }
  }

  private func dataSourceForQuery(_ query: Query) -> RestaurantTableViewDataSource {
    fatalError("Unimplemented")
  }

  private lazy var baseQuery: Query = {
    fatalError("Unimplemented")
  }()

  lazy private var filters: (navigationController: UINavigationController,
                             filtersController: FiltersViewController) = {
    return FiltersViewController.fromStoryboard(delegate: self)
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    backgroundView.image = UIImage(named: "pizza-monster")!
    backgroundView.contentMode = .scaleAspectFit
    backgroundView.alpha = 0.5
    tableView.backgroundView = backgroundView
    tableView.tableFooterView = UIView()
    stackViewHeightConstraint.constant = 0
    activeFiltersStackView.isHidden = true
    tableView.delegate = self

    self.navigationController?.navigationBar.barStyle = .black

    // Uncomment these two lines to enable SECRET HACKER PAGE!!!
    let omgHAX = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(goToHackPage))
    navigationItem.rightBarButtonItems?.append(omgHAX)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.setNeedsStatusBarAppearanceUpdate()
    dataSource.startUpdates()
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    dataSource.stopUpdates()
  }

  deinit {
    dataSource.stopUpdates()
  }

  @IBAction func didTapPopulateButton(_ sender: Any) {
    // Let's confirm that we want to do this
    let confirmationBox = UIAlertController(title: "Populate the database",
      message: "This will add populate the database with several new restaurants and reviews. Would you like to proceed?",
      preferredStyle: .alert)
    confirmationBox.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    confirmationBox.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
      Firestore.firestore().prepopulate()
    }))
    present(confirmationBox, animated: true)
  }

  @IBAction func didTapClearButton(_ sender: Any) {
    filters.filtersController.clearFilters()
    controller(filters.filtersController, didSelectCategory: nil, city: nil, price: nil, sortBy: nil)
  }

  @IBAction func didTapFilterButton(_ sender: Any) {
    present(filters.navigationController, animated: true, completion: nil)
  }

  @objc func goToHackPage(_ sender: Any) {
    if Auth.auth().currentUser != nil {
      let hackPage = HackPageViewController.fromStoryboard()
      self.navigationController?.pushViewController(hackPage, animated: true)
    } else {
      Utils.showSimpleAlert(message: "You must be signed in to be a 1337 hax0r", presentingVC: self)
    }
  }

  override var preferredStatusBarStyle: UIStatusBarStyle {
    set {}
    get {
      return .lightContent
    }
  }

  // MARK: - UITableViewDelegate

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    let restaurant = dataSource[indexPath.row]
    let controller = RestaurantDetailViewController.fromStoryboard(restaurant: restaurant)
    self.navigationController?.pushViewController(controller, animated: true)
  }

}

extension RestaurantsTableViewController: FiltersViewControllerDelegate {

  func query(withCategory category: String?, city: String?, price: Int?, sortBy: String?) -> Query {
    var filtered = baseQuery

    if category == nil && city == nil && price == nil && sortBy == nil {
      stackViewHeightConstraint.constant = 0
      activeFiltersStackView.isHidden = true
    } else {
      stackViewHeightConstraint.constant = 44
      activeFiltersStackView.isHidden = false
    }

    // Advanced queries

    if let category = category, !category.isEmpty {
      filtered = filtered.whereField("category", isEqualTo: category)
    }

    if let city = city, !city.isEmpty {
      filtered = filtered.whereField("city", isEqualTo: city)
    }

    if let price = price {
      filtered = filtered.whereField("price", isEqualTo: price)
    }

    if let sortBy = sortBy, !sortBy.isEmpty {
      filtered = filtered.order(by: sortBy)
    }

    return filtered
  }

  func controller(_ controller: FiltersViewController,
                  didSelectCategory category: String?,
                  city: String?,
                  price: Int?,
                  sortBy: String?) {
    if category == nil && city == nil && price == nil && sortBy == nil {
      stackViewHeightConstraint.constant = 0
      activeFiltersStackView.isHidden = true
    } else {
      stackViewHeightConstraint.constant = 44
      activeFiltersStackView.isHidden = false
    }

    let filtered = query(withCategory: category, city: city, price: price, sortBy: sortBy)

    if let category = category, !category.isEmpty {
      categoryFilterLabel.text = category
      categoryFilterLabel.isHidden = false
    } else {
      categoryFilterLabel.isHidden = true
    }

    if let city = city, !city.isEmpty {
      cityFilterLabel.text = city
      cityFilterLabel.isHidden = false
    } else {
      cityFilterLabel.isHidden = true
    }

    if let price = price {
      priceFilterLabel.text = Utils.priceString(from: price)
      priceFilterLabel.isHidden = false
    } else {
      priceFilterLabel.isHidden = true
    }

    query = filtered
  }

}

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
