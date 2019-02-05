//
//  User.swift
//  InstagramCopy
//
//  Created by Didar Naurzbayev on 2/5/19.
//  Copyright © 2019 Didar Naurzbayev. All rights reserved.
//

import Firebase

class User{
    var username: String!
    var name: String!
    var profileImageUrl: String!
    var uid: String!

    init(uid: String, dictionary: Dictionary<String, AnyObject>) {
        self.uid = uid
        if let username = dictionary["username"] as? String{
            self.username = username
        }
        if let name = dictionary["name"] as? String{
            self.name = name
        }
        if let profileImageUrl = dictionary["profileImageUrl"] as? String{
            self.profileImageUrl = profileImageUrl
        }
    }
}
