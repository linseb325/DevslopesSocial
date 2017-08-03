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
    private var _likes: Int!
    private var _poster: String!
    private var _postID: String!
    private var _ref: DatabaseReference!
    
    
    var caption: String {
        return _caption
    }
    
    var imageURL: String {
        return _imageURL
    }
    
    var likes: Int {
        return _likes
    }
    
    var poster: String {
        return _poster
    }
    
    var postID: String {
        return _postID
    }
    
    var ref: DatabaseReference {
        return _ref
    }
    
    
    
    init(caption: String, imageURL: String, likes: Int, postingUserID: String, postID: String) {
        self._caption = caption
        self._imageURL = imageURL
        self._likes = likes
        self._poster = postingUserID
        self._postID = postID
        self._ref = DataService.ds.REF_POSTS.child(postID)
    }
    
    
    
    init(postID: String, postData: Dictionary<String, Any>) {
        self._postID = postID
        self._ref = DataService.ds.REF_POSTS.child(postID)
        
        if let caption = postData["caption"] as? String {
            self._caption = caption
        }
        if let imageURL = postData["imageURL"] as? String {
            self._imageURL = imageURL
        }
        if let likes = postData["likes"] as? Int {
            self._likes = likes
        }
        if let postingUserID = postData["poster"] as? String {
            self._poster = postingUserID
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

