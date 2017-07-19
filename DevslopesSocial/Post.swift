//
//  Post.swift
//  DevslopesSocial
//
//  Created by Brennan Linse on 7/19/17.
//  Copyright © 2017 Brennan Linse. All rights reserved.
//

import Foundation

class Post {
    private var _caption: String!
    private var _imageURL: String!
    private var _likes: Int!
    private var _postID: String!
    
    var caption: String {
        return _caption
    }
    
    var imageURL: String {
        return _imageURL
    }
    
    var likes: Int {
        return _likes
    }
    
    var postID: String {
        return _postID
    }
    
    init(caption: String, imageURL: String, likes: Int, postID: String) {
        self._caption = caption
        self._imageURL = imageURL
        self._likes = likes
        self._postID = postID
    }
    
    init(postID: String, postData: Dictionary<String, Any>) {
        self._postID = postID

        if let caption = postData["caption"] as? String {
            self._caption = caption
        }
        if let imageURL = postData["imageURL"] as? String {
            self._imageURL = imageURL
        }
        if let likes = postData["likes"] as? Int {
            self._likes = likes
        }
    }
    
    
    
    
    
}

