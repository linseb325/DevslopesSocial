//
//  FeedVC.swift
//  DevslopesSocial
//
//  Created by Brennan Linse on 6/27/17.
//  Copyright © 2017 Brennan Linse. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class FeedVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    
    @IBAction func signOutPressed(_ sender: Any) {
        print("Brennan - Got into signOutPressed")
        
        let didRemoveFromKeychain = KeychainWrapper.standard.removeObject(forKey: KEY_UID)
        print("Brennan - Did remove UID from keychain? -> \(didRemoveFromKeychain)")
        
        do {
            try Auth.auth().signOut()
        } catch let err {
            print("Brennan - error signing out of Firebase: \(err.localizedDescription)")
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    
    
    
    
    
    
    
    
    
}
