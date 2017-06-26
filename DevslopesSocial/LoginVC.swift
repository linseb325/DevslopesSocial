//
//  LoginVC.swift
//  DevslopesSocial
//
//  Created by Brennan Linse on 6/22/17.
//  Copyright © 2017 Brennan Linse. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase

class LoginVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func facebookButtonPressed(_ sender: Any) {
        let facebookLogin = FBSDKLoginManager()
        
        facebookLogin.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            if error != nil {
                print("ERROR: Unable to authenticate with Facebook: \(error.debugDescription)")
            } else if result?.isCancelled == true {
                print("User cancelled Facebook authentication")
            } else {
                print("Successfully authenticated with Facebook")
                let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                self.authenticateFirebase(credential)
            }
        }
    }
    
    func authenticateFirebase(_ credential: AuthCredential) {
        Auth.auth().signIn(with: credential) { (user, error) in
            if error != nil {
                print("ERROR: Unable to authenticate with Firebase: \(error.debugDescription)")
            } else {
                print("Successfully authenticated with Firebase")
            }
        }
    }
    
    
    
    
    
    
    
    
}
