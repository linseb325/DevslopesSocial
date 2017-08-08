//
//  Post.swift
//  DevslopesSocial
//
//  Created by Brennan Linse on 7/19/17.
//  Copyright © 2017 Brennan Linse. All rights reserved.
//

import Foundation
import Firebase

class Post {
    
    private var _caption: String!
    private var _imageURL: String!
    private var _profileImageURL: String!
    private var _likes: Int!
    private var _posterUID: String!
    private var _posterUsername: String!
    private var _postID: String!
    private var _ref: DatabaseReference!
    
    
    var caption: String {
        return _caption
    }
    
    var imageURL: String {
        return _imageURL
    }
    
    var profileImageURL: String {
        return _profileImageURL
    }
    
    var likes: Int {
        return _likes
    }
    
    var posterUID: String {
        return _posterUID
    }
    
    var posterUsername: String {
        return _posterUsername
    }
    
    var postID: String {
        return _postID
    }
    
    var ref: DatabaseReference {
        return _ref
    }
    
    
    
    init(caption: String, imageURL: String, profileImageURL: String, likes: Int, postingUserID: String, postID: String) {
        self._caption = caption
        self._imageURL = imageURL
        self._profileImageURL = profileImageURL
        self._likes = likes
        self._posterUID = postingUserID
        // self._posterUsername = DataService.ds.REF_USERS.child(_posterUID).value(forKey: "username") as? String ?? "ds_user"
        self._postID = postID
        self._ref = DataService.ds.REF_POSTS.child(postID)
    }
    
    
    
    init(postID: String, postData: [String: Any], posterUsername: String, posterProfileImageURL: String) {
        self._postID = postID
        self._ref = DataService.ds.REF_POSTS.child(postID)
        self._posterUsername = posterUsername
        self._profileImageURL = posterProfileImageURL
        
        if let caption = postData["caption"] as? String {
            self._caption = caption
        }
        if let imageURL = postData["imageURL"] as? String {
            self._imageURL = imageURL
        }
        if let likes = postData["likes"] as? Int {
            self._likes = likes
        }
        if let postingUserID = postData["posterUID"] as? String {
            self._posterUID = postingUserID
        }
        
    }
    
    
    
    // Adjusts the post's number of likes in both the local data model and Firebase database.
    func adjustLikes(addLike: Bool) {
        if addLike {
            self._likes = _likes + 1
        } else {
            self._likes = _likes - 1
        }
        self._ref.child("likes").setValue(self._likes)
    }
    
    
    
    
    
    
    
    
    
}

