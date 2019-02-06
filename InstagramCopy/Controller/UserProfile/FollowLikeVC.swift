//
//  FollowLikeVC.swift
//  InstagramCopy
//
//  Created by Didar Naurzbayev on 2/6/19.
//  Copyright © 2019 Didar Naurzbayev. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "FollowCell"

class FollowLikeVC: UITableViewController, FollowCellDelegate {
    
    
    
    //MARK: - Properties
    var viewFollowers = false
    var viewFollowing = false
    
    var uid: String?
    var users = [User]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(FollowLikeCell.self, forCellReuseIdentifier: reuseIdentifier)
        
        //configure nav controler
        if viewFollowers {
            navigationItem.title = "followers"
        } else {
            navigationItem.title = "following"
        }
        
        //fetch users
        fetchUsers()
        
        
        
        
        // clear separator lines
        tableView.separatorColor = .clear
        
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
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! FollowLikeCell
        cell.delegate = self
        cell.user = users[indexPath.row]
        return cell
    }
    
    
    func handleFollowTapped(for cell: FollowLikeCell) {
        
        guard let user = cell.user else { return }
        
        if user.isFollowed {
            
            user.unfollow()
            
            // configure follow button for non followed user
            cell.followButton.setTitle("Follow", for: .normal)
            cell.followButton.setTitleColor(.white, for: .normal)
            cell.followButton.layer.borderWidth = 0
            cell.followButton.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
            
        } else {
            
            user.follow()
            
            // configure follow button for followed user
            cell.followButton.setTitle("Following", for: .normal)
            cell.followButton.setTitleColor(.black, for: .normal)
            cell.followButton.layer.borderWidth = 0.5
            cell.followButton.layer.borderColor = UIColor.lightGray.cgColor
            cell.followButton.backgroundColor = .white
        }
    }
    
    
    func fetchUsers(){
        var ref : DatabaseReference!
        guard let uid = self.uid else { return }
        
        if viewFollowers {
            
            ref = USER_FOLLOWER_REF
        } else {
            ref = USER_FOLLOWING_REF
        }
        
        ref.child(uid).observeSingleEvent(of: .value) { (snapshot) in

            guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
            
            allObjects.forEach({ (snapshot) in
                let userId = snapshot.key
                
                Database.fetchUser(with: userId, completion: { (user) in
                    self.users.append(user)
                    self.tableView.reloadData()
                })

            })
        }
    }
}
