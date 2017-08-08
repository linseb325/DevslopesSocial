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
    
    
    
    // Log the user in automatically via Keychain if allowed.
    override func viewDidAppear(_ animated: Bool) {
        if let _ = KeychainWrapper.standard.string(forKey: KEY_UID) {
            // There is a UID stored in Keychain, but there might not be an associated username.
            DataService.ds.REF_CURRENT_USER.child("username").observeSingleEvent(of: .value, with: { (snapshot) in
                if let _ = snapshot.value as? NSNull {
                    print("Brennan - Found null")
                    // There is no username stored in the database for the current user.
                    let emptyUserData: [String: String] = [:]
                    self.performSegue(withIdentifier: "toProfileSetupVC", sender: emptyUserData)
                } else {
                    print("Brennan - Found a username: \(snapshot.value!)")
                    // There is a username stored in the database for the current user.
                    self.performSegue(withIdentifier: "straightToFeedVC", sender: nil)
                }
            })
        }
    }
    
    
    
    // User would like to authenticate with Facebook.
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
                self.authenticateFirebaseViaFacebook(credential)
            }
        }
    }
    
    
    
    // Authenticates with Firebase after doing so with Facebook. Only called from the facebookButtonPressed method.
    func authenticateFirebaseViaFacebook(_ credential: AuthCredential) {
        Auth.auth().signIn(with: credential) { (user, error) in
            if error != nil {
                print("Brennan - ERROR: Unable to sign in with Firebase: \(error.debugDescription)")
            } else {
                // Successfully signed in with Firebase via Facebook.
                print("Brennan - Successfully signed in with Firebase via Facebook")
                if let user = user {
                    let userData = ["provider": credential.provider]
                    self.completeSignIn(id: user.uid, userData: userData)
                }
            }
        }
    }
    
    // User would like to authenticate with Firebase.
    @IBAction func signInPressed(_ sender: FancyButton) {
        if let emailAddress = emailTextField.text, let password = passwordTextField.text {
            Auth.auth().signIn(withEmail: emailAddress, password: password, completion: { (user, error) in
                if error == nil {
                    // The user already exists.
                    print("Brennan - Existing email user signed in with Firebase")
                    if let user = user {
                        let userData = ["provider": user.providerID]
                        self.completeSignIn(id: user.uid, userData: userData)
                    }
                } else {
                    // New user. Try to create a new Firebase Auth user.
                    Auth.auth().createUser(withEmail: emailAddress, password: password, completion: { (user, error) in
                        if error != nil {
                            print("Brennan - Unable to create new user with Firebase Auth: \(error.debugDescription)")
                        } else {
                            print("Brennan - Successfully created new user with Firebase Auth")
                            if let user = user {
                                let userData = ["provider": user.providerID]
                                self.completeSignIn(id: user.uid, userData: userData)
                            }
                        }
                    })
                }
            })
        }
    }
    
    
    
    func completeSignIn(id: String, userData: [String: String]) {
        let saveSuccessful = KeychainWrapper.standard.set(id, forKey: KEY_UID)
        print("Brennan - Was the UID save to keychain successful? -> \(saveSuccessful)")
        if saveSuccessful {
            // At this point, userData contains only provider information.
            // Check to see if the user needs to set up his/her profile.
            DataService.ds.REF_CURRENT_USER.child("username").observeSingleEvent(of: .value, with: { (snapshot) in
                if let _ = snapshot.value as? NSNull {
                    print("Brennan - Found null. New user needs to set up a profile.")
                    // There is no username stored in the database for the current user.
                    self.performSegue(withIdentifier: "toProfileSetupVC", sender: userData)
                } else {
                    print("Brennan - Found a username, so an existing user must be signing back in without Keychain: \(snapshot.value!)")
                    // There is a username stored in the database for the current user.
                    self.performSegue(withIdentifier: "straightToFeedVC", sender: nil)
                }
            })
        }
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "toProfileSetupVC" {
                // New user. Needs to set up a profile.
                if let profileSetupScreen = segue.destination as? ProfileSetupVC {
                    profileSetupScreen.userDataFromLoginVC = sender as? [String: String] ?? [:]
                }
            } else if identifier == "straightToFeedVC" {
                // Existing user. Go straight to the feed.
            } else {
                print("Brennan - Problem with segue identifiers. Couldn't prepare for the segue correctly. Identifier is: \(identifier)")
            }
        } else {
            print("Brennan - the segue from LoginVC has no identifier for some reason!")
        }
    }
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    
    
    
    
    
    
}
