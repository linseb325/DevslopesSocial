//
//  ProfileSetupVC.swift
//  DevslopesSocial
//
//  Created by Brennan Linse on 8/5/17.
//  Copyright © 2017 Brennan Linse. All rights reserved.
//

import UIKit
import Firebase

class ProfileSetupVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    
    @IBOutlet weak var usernameTF: FancyTextField!
    @IBOutlet weak var profileImageView: RoundImageView!
    
    
    var userDataFromLoginVC: [String: String]!
    var imagePicker = UIImagePickerController()
    var pickedAnImage = false
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        usernameTF.delegate = self
    }

    
    
    @IBAction func imageTapped(_ sender: Any) {
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("Brennan - did finish picking image - got into method")
        if let selectedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            print("Brennan - Got an image from the image picker")
            self.profileImageView.image = selectedImage
            self.pickedAnImage = true
        } else {
            print("Brennan - Didn't retrieve an image from the image picker")
        }
        self.imagePicker.dismiss(animated: true, completion: nil)
    }
    
    
    
    @IBAction func finishedButtonPressed(_ sender: Any) {
        // Check to make sure there's a username.
        guard let username = usernameTF.text, !usernameTF.text!.isEmpty else {
            print("Brennan - You need to enter a username!")
            return
        }
        // FOR THE FUTURE: DO A QUERY TO MAKE SURE THE USERNAME IS UNIQUE AMONG ALL USERS.
        
        guard pickedAnImage, let selectedImage = self.profileImageView.image else {
            print("Brennan - You need to select a profile image!")
            return
        }
        
        // Save the profile image to Firebase Storage.
        if let imageData = UIImageJPEGRepresentation(selectedImage, 0.2) {
            let imageID = NSUUID().uuidString
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            DataService.ds.REF_PROFILE_IMAGES.child(imageID).putData(imageData, metadata: metadata, completion: { (metadata, error) in
                if error != nil {
                    print("Brennan - Error uploading image from new post to FB storage: \(error!.localizedDescription)")
                } else {
                    print("Brennan - Successfully uploaded image to FB storage.")
                    if let downloadURL = metadata?.downloadURL()?.absoluteString {
                        print("Brennan - download URL for profile pic is: \(downloadURL)")
                        self.userDataFromLoginVC["profileImageURL"] = downloadURL
                        print("Brennan - just updated profileImageURL in userData.")
                    } else {
                        print("Brennan - Couldn't get download URL from FB storage for the profile picture for some reason.")
                    }
                }
                // Save the username and other user data to Firebase.
                self.userDataFromLoginVC["username"] = username
                DataService.ds.createFirebaseDBUser(uid: DataService.ds.REF_CURRENT_USER.key, userData: self.userDataFromLoginVC)
                self.performSegue(withIdentifier: "toFeedVC", sender: nil)
            })
        }
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    
    
    
    
    
    
}
