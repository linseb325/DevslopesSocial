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

class LoginVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: FancyTextField!
    @IBOutlet weak var passwordTextField: FancyTextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func facebookButtonPressed(_ sender: Any) {
        let facebookLogin = FBSDKLoginManager()
        
        facebookLogin.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            if error != nil {
                print("Brennan - Unable to authenticate with Facebook: \(error.debugDescription)")
            } else if result?.isCancelled == true {
                print("Brennan - User cancelled Facebook authentication")
            } else {
                print("Brennan - Successfully authenticated with Facebook")
                let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                self.authenticateFirebase(credential)
            }
        }
    }
    
    func authenticateFirebase(_ credential: AuthCredential) {
        Auth.auth().signIn(with: credential) { (user, error) in
            if error != nil {
                print("Brennan - ERROR: Unable to authenticate with Firebase: \(error.debugDescription)")
            } else {
                print("Brennan - Successfully authenticated with Firebase in 'authenticateFirebase' method")
            }
        }
    }
    
    
    @IBAction func signInPressed(_ sender: FancyButton) {
        if let emailAddress = emailTextField.text, let password = passwordTextField.text {
            Auth.auth().signIn(withEmail: emailAddress, password: password, completion: { (user, error) in
                if error == nil {
                    print("Brennan - Email user authenticated with Firebase")
                } else {
                    // Try to create a new user
                    Auth.auth().createUser(withEmail: emailAddress, password: password, completion: { (user, error) in
                        if error != nil {
                            print("Brennan - Unable to create new user with Firebase: \(error.debugDescription)")
                        } else {
                            print("Brennan - Successfully created new user with Firebase")
                        }
                    })
                }
            })
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    
    
    
}
