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

import UIKit
import FirebaseAuth
import FirebaseAuthUI
import FirebaseFirestore
import SDWebImage

class ProfileViewController: UIViewController {

  static func fromStoryboard(_ storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil))
      -> ProfileViewController {
    return storyboard.instantiateViewController(withIdentifier: "ProfileViewController")
        as! ProfileViewController
  }

  /// The current user displayed by the controller. Setting this property has side effects.
  fileprivate var user: User? = nil {
    didSet {
      populate(user: user)
      if let user = user {
        populateReviews(forUser: user)
      } else {
        dataSource?.reviews.stopListening()
        dataSource = nil
        tableView.backgroundView = tableBackgroundLabel
        tableView.reloadData()
      }
    }
  }

  lazy private var tableBackgroundLabel: UILabel = {
    let label = UILabel(frame: tableView.frame)
    label.textAlignment = .center
    return label
  }()

  private var dataSource: ReviewTableViewDataSource? = nil
  private var authListener: AuthStateDidChangeListenerHandle? = nil
  
  @IBOutlet private var tableView: UITableView!

  @IBOutlet private var profileImageView: UIImageView!
  @IBOutlet private var usernameLabel: UILabel!
  @IBOutlet private var viewRestaurantsButton: UIButton!

  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.delegate = self
    tableBackgroundLabel.text = "There aren't any reviews here."
    tableView.backgroundView = tableBackgroundLabel
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    setUser(firebaseUser: Auth.auth().currentUser)
    Auth.auth().addStateDidChangeListener { (auth, newUser) in
      self.setUser(firebaseUser: newUser)
    }
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    if user == nil {
      presentLoginController()
    }
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    if let listener = authListener {
      Auth.auth().removeStateDidChangeListener(listener)
    }
  }

  fileprivate func setUser(firebaseUser: FirebaseAuth.UserInfo?) {
    if let firebaseUser = firebaseUser {
      user = User(user: firebaseUser)
    } else {
      user = nil
    }
  }

  fileprivate func populate(user: User?) {
    if let user = user {
      profileImageView.sd_setImage(with: user.photoURL)
      usernameLabel.text = user.name
      viewRestaurantsButton.isEnabled = true
    } else {
      profileImageView.image = nil
      usernameLabel.text = "Not logged in"
      viewRestaurantsButton.isEnabled = false
    }
  }

  fileprivate func populateReviews(forUser user: User) {
    let query = Firestore.firestore().reviews.whereField("userInfo.userID", isEqualTo: user.userID)
    dataSource = ReviewTableViewDataSource(query: query) { [weak self] (changes) in
      self?.tableView.reloadData()
      guard let reviews = self?.dataSource?.reviews else { return }
      if reviews.count > 0 {
        self?.tableView.backgroundView = nil
      } else {
        self?.tableView.backgroundView = self?.tableBackgroundLabel
      }
    }
    dataSource?.reviews.listen()
    tableView.dataSource = dataSource
  }

  fileprivate func presentLoginController() {
    guard let authUI = FUIAuth.defaultAuthUI() else { return }
    guard authUI.auth?.currentUser == nil else {
      print("Attempted to present auth flow while already logged in")
      return
    }
    authUI.providers = []
    let controller = authUI.authViewController()
    self.present(controller, animated: true, completion: nil)
  }

  @IBAction private func didTapViewRestaurantsButton(_ sender: Any) {
    // TODO: Segue to a new controller listing the user's owned restaurants.
  }

  @IBAction private func didTapSignOutButton(_ sender: Any) {
    do {
      try Auth.auth().signOut()
    } catch let error {
      print("Error signing out: \(error)")
    }
  }
}

// MARK: - UITableViewDelegate

extension ProfileViewController: UITableViewDelegate {

  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 0
  }

}
