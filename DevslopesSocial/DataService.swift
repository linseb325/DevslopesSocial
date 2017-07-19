//
//  DataService.swift
//  DevslopesSocial
//
//  Created by Brennan Linse on 7/17/17.
//  Copyright © 2017 Brennan Linse. All rights reserved.
//

import Foundation
import Firebase

let _REF_DATABASE = Database.database().reference()

class DataService {
    
    static let ds = DataService()
    
    // private var REF_DATABASE = DATABASE_REF
    private var _REF_POSTS = _REF_DATABASE.child("posts")
    private var _REF_USERS = _REF_DATABASE.child("users")
    
    var REF_BASE: DatabaseReference {
        return _REF_DATABASE
    }
    
    var REF_POSTS: DatabaseReference {
        return self._REF_POSTS
    }
    
    var REF_USERS: DatabaseReference {
        return self._REF_USERS
    }
    
    
    func createFirebaseDBUser(uid: String, userData: [String: String]) {
        REF_USERS.child(uid).updateChildValues(userData)
    }
    
    
    
    
    
    
    
    
    
}







