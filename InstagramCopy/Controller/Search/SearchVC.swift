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

class SearchVC: UITableViewController {
    
    //MARK: - Properties
    var users = [User]()
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //register cell classes
        tableView.register(SearchUserCell.self, forCellReuseIdentifier: reuseIdentifier)
        
        //separator insets
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 64, bottom: 0, right: 0)
        
        configureNavController()
        
        fetchUser()
    }
    
    
    
    // MARK: - Table view
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! SearchUserCell
        
        cell.user = users[indexPath.row]
        
        
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = users[indexPath.row]
        
        // create instance of user profile vc
        let userProfileVC = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
        
        //passes user from searchVC to UserProfileVC
        userProfileVC.user = user
        
        // push view controller
        navigationController?.pushViewController(userProfileVC, animated: true)
        
        
    }
    
    
    // MARK: - Handlers
    func configureNavController(){
        navigationItem.title = "Explore"
    }
    // MARK: - Fetch users
    
    func fetchUser(){
        Database.database().reference().child("users").observe(.childAdded) { (snapshot) in
            
            
            //uid
            let uid = snapshot.key
            
            //snapshot value cast as dictionary

            Database.fetchUser(with: uid, completion: { (user) in
                
                self.users.append(user)
                self.tableView.reloadData()
            })
        }
    }
    
    
}
