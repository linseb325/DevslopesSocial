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
import FirebaseAuth
import SwiftKeychainWrapper

class LoginVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: FancyTextField!
    @IBOutlet weak var passwordTextField: FancyTextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let _ = KeychainWrapper.standard.string(forKey: KEY_UID) {
            print("Brennan - Found UID in keychain. Logging user in.")
            performSegue(withIdentifier: "toFeedVC", sender: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func facebookButtonPressed(_ sender: Any) {
        let facebookLogin = FBSDKLoginManager()
        
        facebookLogin.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            if error != nil {
                print("Brennan - Unable to sign in with Facebook: \(error.debugDescription)")
            } else if result?.isCancelled == true {
                print("Brennan - User cancelled Facebook sign-in")
            } else {
                print("Brennan - Successfully signed in with Facebook")
                let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                self.authenticateFirebase(credential)
            }
        }
    }
    
    // Authenticates with Firebase after doing so with Facebook. Only called from the facebookButtonPressed method.
    func authenticateFirebase(_ credential: AuthCredential) {
        Auth.auth().signIn(with: credential) { (user, error) in
            if error != nil {
                print("Brennan - ERROR: Unable to sign in with Firebase: \(error.debugDescription)")
            } else {
                print("Brennan - Successfully signed in with Firebase in 'authenticateFirebase' method")
                if let user = user {
                    self.completeSignIn(id: user.uid)
                }
            }
        }
    }
    
    // User is signing in with e-mail/password
    @IBAction func signInPressed(_ sender: FancyButton) {
        if let emailAddress = emailTextField.text, let password = passwordTextField.text {
            Auth.auth().signIn(withEmail: emailAddress, password: password, completion: { (user, error) in
                if error == nil {
                    print("Brennan - Existing email user signed in with Firebase")
                    if let user = user {
                        self.completeSignIn(id: user.uid)
                    }
                } else {
                    // Try to create a new user
                    Auth.auth().createUser(withEmail: emailAddress, password: password, completion: { (user, error) in
                        if error != nil {
                            print("Brennan - Unable to create new user with Firebase: \(error.debugDescription)")
                        } else {
                            print("Brennan - Successfully created new user with Firebase")
                            if let user = user {
                                self.completeSignIn(id: user.uid)
                            }
                        }
                    })
                }
            })
        }
    }
    
    func completeSignIn(id: String) {
        let saveSuccessful = KeychainWrapper.standard.set(id, forKey: KEY_UID)
        print("Brennan - Was the UID save to keychain successful? -> \(saveSuccessful)")
        if saveSuccessful {
            performSegue(withIdentifier: "toFeedVC", sender: nil)
        }
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    
    
    
}
