//
//  DataService.swift
//  DevslopesSocial
//
//  Created by Brennan Linse on 7/17/17.
//  Copyright © 2017 Brennan Linse. All rights reserved.
//

import Foundation
import Firebase
import SwiftKeychainWrapper

let DATABASE_REF_BASE = Database.database().reference()
let STORAGE_REF_BASE = Storage.storage().reference()

class DataService {
    
    static let ds = DataService()
    
    private var _REF_POSTS = DATABASE_REF_BASE.child("posts")
    private var _REF_USERS = DATABASE_REF_BASE.child("users")
    
    private var _REF_POST_IMAGES = STORAGE_REF_BASE.child("post-pics")
    private var _REF_PROFILE_IMAGES = STORAGE_REF_BASE.child("profile-pics")
    
    var REF_BASE: DatabaseReference {
        return DATABASE_REF_BASE
    }
    
    var REF_POSTS: DatabaseReference {
        return self._REF_POSTS
    }
    
    var REF_USERS: DatabaseReference {
        return self._REF_USERS
    }
    
    var REF_CURRENT_USER: DatabaseReference {
        let uid = KeychainWrapper.standard.string(forKey: KEY_UID)
        return self._REF_USERS.child(uid!)
    }
    
    var REF_POST_IMAGES: StorageReference {
        return self._REF_POST_IMAGES
    }
    
    var REF_PROFILE_IMAGES: StorageReference {
        return self._REF_PROFILE_IMAGES
    }
    
    
    func createFirebaseDBUser(uid: String, userData: [String: String]) {
        REF_USERS.child(uid).updateChildValues(userData)
    }
    
    
    
    
    
    
    
    
    
}







