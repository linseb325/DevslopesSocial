//
//  AccountSettingsVC.swift
//  DevslopesSocial
//
//  Created by Brennan Linse on 8/10/17.
//  Copyright © 2017 Brennan Linse. All rights reserved.
//

import UIKit
import Firebase

class AccountSettingsVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var currentProfileImageImageView: RoundImageView!
    @IBOutlet weak var currentUsernameLabel: UILabel!
    @IBOutlet weak var newUsernameTF: FancyTextField!
    @IBOutlet weak var newImageImageView: RoundImageView!
    
    var imagePicker: UIImagePickerController = UIImagePickerController()
    var pickedAnImage = false
    var feedScreenRef: FeedVC!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        newUsernameTF.delegate = self
        
        
        DataService.ds.REF_CURRENT_USER.observeSingleEvent(of: .value, with: { (snapshot) in
            if let userData = snapshot.value as? [String: Any] {
                if let existingImageURL = userData["profileImageURL"] as? String {
                    if let profileImageFromCache = FeedVC.imageCache.object(forKey: existingImageURL as NSString) {
                        // Get the profile image from the cache.
                        self.currentProfileImageImageView.image = profileImageFromCache
                        print("Brennan - Found current profile image in cache.")
                    } else {
                        // Download the profile image from Storage.
                        let existingImageRef = Storage.storage().reference(forURL: existingImageURL)
                        existingImageRef.getData(maxSize: 2 * 1024 * 1024, completion: { (data, error) in
                            if error != nil {
                                print("Brennan - Error downloading existing profile image from Storage: \(error!.localizedDescription)")
                            } else {
                                if let imageData = data {
                                    if let img = UIImage(data: imageData) {
                                        self.currentProfileImageImageView.image = img
                                        print("Brennan - Got existing profile image from Storage.")
                                    }
                                }
                            }
                        })
                    }
                }
                
                if let existingUsername = userData["username"] as? String {
                    self.currentUsernameLabel.text = existingUsername
                }
            }
        })
        
        
        
        
        
        
    }
    
    
    
    @IBAction func finishedButtonPressed(_ sender: Any) {
        
        // Change the username in Firebase database if the user types one.
        if let newUsername = self.newUsernameTF.text, !newUsername.isEmpty {
            DataService.ds.REF_CURRENT_USER.child("username").setValue(newUsername)
            print("Brennan - Set new username in database: \(newUsername)")
        }
        
        // Delete the old image from Firebase storage and store the new one if the user chooses one. Also, update the URL in Firebase database.
        if let newProfileImage = self.newImageImageView.image, self.pickedAnImage {
            // Delete the old image from Storage.
            
            DataService.ds.REF_CURRENT_USER.observeSingleEvent(of: .value, with: { (snapshot) in
                if let userDict = snapshot.value as? [String: Any] {
                    if let oldProfileImageURL = userDict["profileImageURL"] as? String {
                        // Delete the old profile image from Firebase Storage.
                        DataService.ds.REF_PROFILE_IMAGES.child(oldProfileImageURL).delete(completion: { (error) in
                            if error != nil {
                                print("Brennan - Error deleting old profile image from Storage: \(error!.localizedDescription)")
                            } else {
                                print("Brennan - Deleted the old profile image from Storage.")
                            }
                        })
                    }
                }
            })
            
            // Now, store the new profile image in Firebase Storage and the new URL in the database.
            if let imageData = UIImageJPEGRepresentation(newProfileImage, 0.2) {
                let imageUUID = NSUUID().uuidString
                let metadata = StorageMetadata()
                metadata.contentType = "image/jpeg"
                DataService.ds.REF_PROFILE_IMAGES.child(imageUUID).putData(imageData, metadata: metadata, completion: { (metadata, error) in
                    if error != nil {
                        print("Brennan - Error uploading updated profile image to Storage: \(error!.localizedDescription)")
                    } else {
                        print("Brennan - Successfully uploaded image to Storage.")
                        if let downloadURL = metadata?.downloadURL()?.absoluteString {
                            // Update profile image URL in the database.
                            DataService.ds.REF_CURRENT_USER.child("profileImageURL").setValue(downloadURL)
                            print("Brennan - Saved the new profile image URL in the database.")
                            self.feedScreenRef.updateFeed()
                        } else {
                            print("Brennan - Couldn't get download URL from Storage for some reason.")
                        }
                    }
                })
            }
            
        } else {
            self.feedScreenRef.updateFeed()
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func backButtonPressed(_ sender: Any) {
        
        // Show an alert asking the user if he/she wants to discard changes.
        let alert = UIAlertController(title: "Alert", message: "Are you sure you want to go back to the feed? Your changes will be discarded.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "YES, discard changes", style: .destructive, handler: { (action) in
            self.dismiss(animated: true, completion: { 
                print("Brennan - Profile changes discarded. Returning to the feed.")
            })
        }))
        
        alert.addAction(UIAlertAction(title: "NO, stay here", style: .default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
    
    @IBAction func addImageTapped(_ sender: Any) {
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.newImageImageView.image = pickedImage
            self.pickedAnImage = true
        } else {
            self.pickedAnImage = false
        }
        self.imagePicker.dismiss(animated: true, completion: nil)
    }
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    
    
    
    
    
}
