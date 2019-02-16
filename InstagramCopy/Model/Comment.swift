//
//  Comment.swift
//  InstagramCopy
//
//  Created by Didar Naurzbayev on 2/14/19.
//  Copyright © 2019 Didar Naurzbayev. All rights reserved.
//

import Foundation
import Firebase

class Comment {
    
    var uid: String!
    var commentText: String!
    var creationDate: Date!
    var user: User?
    
    init(user: User, dictionary: Dictionary<String, AnyObject>) {
        
        self.user = user
        
        if let uid = dictionary["uid"] as? String {
            self.uid = uid
        }
        
        if let commentText = dictionary["commentText"] as? String {
            self.commentText = commentText
        }
        
        if let creationDate = dictionary["creationDate"] as? Double {
            self.creationDate = Date(timeIntervalSince1970: creationDate)
        }
    }
}
