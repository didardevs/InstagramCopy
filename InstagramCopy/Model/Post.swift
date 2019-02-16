//
//  Post.swift
//  InstagramCopy
//
//  Created by Didar Naurzbayev on 2/7/19.
//  Copyright © 2019 Didar Naurzbayev. All rights reserved.
//

import Firebase
import FirebaseDatabase
import Foundation

class Post {
    
    var caption: String!
    var likes: Int!
    var imageUrl: String!
    var ownerUid: String!
    var creationDate: Date!
    var postId: String!
    var user: User?
    var didLike = false
    
    init(postId: String!, user: User, dictionary: Dictionary<String, AnyObject>) {
        
        self.postId = postId
        
        self.user = user
        
        if let caption = dictionary["caption"] as? String {
            self.caption = caption
        }
        
        if let likes = dictionary["likes"] as? Int {
            self.likes = likes
        }
        
        if let imageUrl = dictionary["imageUrl"] as? String {
            self.imageUrl = imageUrl
        }
        
        if let ownerUid = dictionary["ownerUid"] as? String {
            self.ownerUid = ownerUid
        }
        
        if let creationDate = dictionary["creationDate"] as? Double {
            self.creationDate = Date(timeIntervalSince1970: creationDate)
        }
    }
    
    func adjustLikes(addLike: Bool, completion: @escaping(Int) -> ()) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        // UPDATE: Unwrap post id to work with firebase
        guard let postId = self.postId else { return }
        
        if addLike {
            USER_LIKES_REF.child(currentUid).updateChildValues([postId: 1], withCompletionBlock: { (err, ref) in
               
                
                POST_LIKES_REF.child(self.postId).updateChildValues([currentUid: 1], withCompletionBlock: { (err, ref) in
                    self.likes = self.likes + 1
                    self.didLike = true
                    POSTS_REF.child(self.postId).child("likes").setValue(self.likes)
                    completion(self.likes)
                })
            })
        } else {
            USER_LIKES_REF.child(currentUid).child(postId).observeSingleEvent(of: .value, with: { (snapshot) in
                if let notificationID = snapshot.value as? String {
                    NOTIFICATIONS_REF.child(self.ownerUid).child(notificationID).removeValue(completionBlock: { (err, ref) in
                        self.removeLike(withCompletion: { (likes) in
                            completion(likes)
                        })
                    })
                } else {
                    self.removeLike(withCompletion: { (likes) in
                        completion(likes)
                    })
                }
            })
        }
    }
    
    func removeLike(withCompletion completion: @escaping (Int) -> ()) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        USER_LIKES_REF.child(currentUid).child(self.postId).removeValue(completionBlock: { (err, ref) in
            
            POST_LIKES_REF.child(self.postId).child(currentUid).removeValue(completionBlock: { (err, ref) in
                guard self.likes > 0 else { return }
                self.likes = self.likes - 1
                self.didLike = false
                POSTS_REF.child(self.postId).child("likes").setValue(self.likes)
                completion(self.likes)
            })
        })
    }
    
    
}
