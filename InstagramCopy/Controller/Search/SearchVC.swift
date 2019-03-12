//
//  SearchVC.swift
//  InstagramCopy
//
//  Created by Didar Naurzbayev on 2/4/19.
//  Copyright © 2019 Didar Naurzbayev. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

private let reuseIdentifier = "SearchUserCell"

class SearchVC: UITableViewController, UISearchBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Properties
    
    var users = [User]()
    var filteredUsers = [User]()
    var searchBar = UISearchBar()
    var inSearchMode = false
    var collectionView: UICollectionView!
    var collectionViewEnabled = true
    var posts = [Post]()
    var currentKey: String?
    var userCurrentKey: String?
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // register cell classes
        tableView.register(SearchUserCell.self, forCellReuseIdentifier: reuseIdentifier)
        
        // UPDATE: - remove separators
        tableView.separatorStyle = .none
        
        // configure search bar
        configureSearchBar()
        
        // configure collection view
        configureCollectionView()
        
        // configure refresh control
        configureRefreshControl()
        
        // fetch posts
        fetchPosts()
    }
    
    // MARK: - UITableView
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if inSearchMode {
            return filteredUsers.count
        } else {
            return users.count
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if users.count > 3 {
            if indexPath.item == users.count - 1 {
                fetchUsers()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var user: User!
        
        if inSearchMode {
            user = filteredUsers[indexPath.row]
        } else {
            user = users[indexPath.row]
        }
        
        // create instance of user profile vc
        let userProfileVC = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
        
        // passes user from searchVC to userProfileVC
        userProfileVC.user = user
        
        // push view controller
        navigationController?.pushViewController(userProfileVC, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! SearchUserCell
        
        var user: User!
        
        if inSearchMode {
            user = filteredUsers[indexPath.row]
        } else {
            user = users[indexPath.row]
        }
        
        cell.user = user
        
        return cell
    }
    
    // MARK: - UICollectionView
    
    func configureCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height - (tabBarController?.tabBar.frame.height)! - (navigationController?.navigationBar.frame.height)!)
        
        collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = .white
        collectionView.register(SearchPostCell.self, forCellWithReuseIdentifier: "SearchPostCell")
        
        configureRefreshControl()
        
        tableView.addSubview(collectionView)
        tableView.separatorColor = .clear
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 2) / 3
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if posts.count > 20 {
            if indexPath.item == posts.count - 1 {
                fetchPosts()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchPostCell", for: indexPath) as! SearchPostCell
        
        cell.post = posts[indexPath.item]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let feedVC = FeedVC(collectionViewLayout: UICollectionViewFlowLayout())
        feedVC.viewSinglePost = true
        feedVC.post = posts[indexPath.item]
        navigationController?.pushViewController(feedVC, animated: true)
    }
    
    // MARK: - UISearchBar
    
    func configureSearchBar() {
        searchBar.sizeToFit()
        searchBar.delegate = self
        navigationItem.titleView = searchBar
        searchBar.barTintColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
        searchBar.tintColor = .black
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
        
        fetchUsers()
        
        collectionView.isHidden = true
        collectionViewEnabled = false
        
        tableView.separatorColor = .lightGray
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        let searchText = searchText.lowercased()
        
        if searchText.isEmpty || searchText == " " {
            inSearchMode = false
            tableView.reloadData()
        } else {
            inSearchMode = true
            filteredUsers = users.filter({ (user) -> Bool in
                return user.username.contains(searchText)
            })
            tableView.reloadData()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        searchBar.showsCancelButton = false
        searchBar.text = nil
        inSearchMode = false
        
        collectionViewEnabled = true
        collectionView.isHidden = false
        
        tableView.separatorColor = .clear
        tableView.reloadData()
    }
    
    // MARK: - Handlers
    
    @objc func handleRefresh() {
        posts.removeAll(keepingCapacity: false)
        self.currentKey = nil
        fetchPosts()
        collectionView?.reloadData()
    }
    
    func configureRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        self.tableView.refreshControl = refreshControl
    }
    
    // MARK: - API
    
    func fetchUsers() {
        
        if userCurrentKey == nil {
            USER_REF.queryLimited(toLast: 4).observeSingleEvent(of: .value) { (snapshot) in
                
                guard let first = snapshot.children.allObjects.first as? DataSnapshot else { return }
                guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
                
                allObjects.forEach({ (snapshot) in
                    let uid = snapshot.key
                    
                    Database.fetchUser(with: uid, completion: { (user) in
                        self.users.append(user)
                        self.tableView.reloadData()
                    })
                })
                self.userCurrentKey = first.key
            }
        } else {
            USER_REF.queryOrderedByKey().queryEnding(atValue: userCurrentKey).queryLimited(toLast: 5).observeSingleEvent(of: .value, with: { (snapshot) in
                
                guard let first = snapshot.children.allObjects.first as? DataSnapshot else { return }
                guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
                
                allObjects.forEach({ (snapshot) in
                    let uid = snapshot.key
                    
                    if uid != self.userCurrentKey {
                        Database.fetchUser(with: uid, completion: { (user) in
                            self.users.append(user)
                            self.tableView.reloadData()
                        })
                    }
                })
                self.userCurrentKey = first.key
            })
        }
    }
    
    func fetchPosts() {
        if currentKey == nil {
            
            // inital data pull
            POSTS_REF.queryLimited(toLast: 21).observeSingleEvent(of: .value, with: { (snapshot) in
                self.tableView.refreshControl?.endRefreshing()
                
                guard let first = snapshot.children.allObjects.first as? DataSnapshot else { return }
                guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
                
                allObjects.forEach({ (snapshot) in
                    let postId = snapshot.key
                    
                    Database.fetchPost(with: postId, completion: { (post) in
                        self.posts.append(post)
                        self.collectionView.reloadData()
                    })
                })
                self.currentKey = first.key
            })
        } else {
            
            // paginate here
            POSTS_REF.queryOrderedByKey().queryEnding(atValue: self.currentKey).queryLimited(toLast: 10).observeSingleEvent(of: .value, with: { (snapshot) in
                
                guard let first = snapshot.children.allObjects.first as? DataSnapshot else { return }
                guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
                
                allObjects.forEach({ (snapshot) in
                    let postId = snapshot.key
                    
                    if postId != self.currentKey {
                        Database.fetchPost(with: postId, completion: { (post) in
                            self.posts.append(post)
                            self.collectionView.reloadData()
                        })
                    }
                })
                self.currentKey = first.key
            })
        }
    }
}
