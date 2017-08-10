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

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imageAddImageView: RoundImageView!
    @IBOutlet weak var captionTextField: FancyTextField!
    
    
    var posts = [Post]()
    var imagePickerController: UIImagePickerController!
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    var needsToAddImage = true
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.imagePickerController = UIImagePickerController()
        self.imagePickerController.allowsEditing = true
        self.imagePickerController.delegate = self
        
        self.captionTextField.delegate = self
        
        // Update the table view (feed) whenever a change is made.
        DataService.ds.REF_POSTS.observe(.value, with: { (snapshot) in
            print("Brennan - Observer at posts reference fired")
            if let snaps = snapshot.children.allObjects as? [DataSnapshot] {
                self.posts.removeAll()
                for snap in snaps.reversed() {
                    if let postDict = snap.value as? [String: Any] {
                        let posterUID = postDict["posterUID"]! as! String
                        // Observer for retrieving poster's username and profile image URL.
                        DataService.ds.REF_USERS.child(posterUID).observeSingleEvent(of: .value, with: { (snapshot) in
                            if let posterDict = snapshot.value as? [String: Any] {
                                if let posterUsername = posterDict["username"] as? String, let posterProfileImageURL = posterDict["profileImageURL"] as? String {
                                    let post = Post(postID: snap.key, postData: postDict, posterUsername: posterUsername, posterProfileImageURL: posterProfileImageURL)
                                    self.posts.append(post)
                                    if self.posts.count == snaps.count {
                                        print("Brennan - Reloading table view data.")
                                        self.tableView.reloadData()
                                    }
                                }
                            }
                        })
                    }
                }
            }
        })
    }
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = self.posts[indexPath.row]
        var postImg: UIImage?; var profileImg: UIImage?
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as? PostCell {
            DispatchQueue.global().sync {
                if let postImageFromCache = FeedVC.imageCache.object(forKey: post.imageURL as NSString) {
                    postImg = postImageFromCache
                    print("Brennan - Got post image from cache.")
                }
                if let profileImageFromCache = FeedVC.imageCache.object(forKey: post.profileImageURL as NSString) {
                    profileImg = profileImageFromCache
                    print("Brennan - Got profile image from cache.")
                }
                cell.configureCell(post: post, postImage: postImg, profileImage: profileImg)
            }
            return cell
        } else {
            print("Brennan - Didn't dequeue a reusable PostCell for some reason. Returning a generic PostCell.")
            return PostCell()
        }
    }
    
    
    
    @IBAction func signOutPressed(_ sender: Any) {
        let didRemoveFromKeychain = KeychainWrapper.standard.removeObject(forKey: KEY_UID)
        print("Brennan - In signOutPressed: Did remove UID from keychain? -> \(didRemoveFromKeychain)")
        
        do {
            try Auth.auth().signOut()
        } catch {
            print("Brennan - error signing out of Firebase: \(error.localizedDescription)")
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let img = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.imageAddImageView.image = img
            self.needsToAddImage = false
        } else {
            print("Brennan - A valid image wasn't selected!")
        }
        self.imagePickerController.dismiss(animated: true, completion: nil)
    }
    
    
    
    @IBAction func addImageTapped(_ sender: Any) {
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    
    
    @IBAction func postButtonPressed(_ sender: Any) {
        guard let caption = self.captionTextField.text, !caption.isEmpty else {
            print("Brennan - Caption is empty!")
            return
        }
        guard !self.needsToAddImage, let currentImage = self.imageAddImageView.image else {
            print("Brennan - You didn't select an image!")
            return
        }
        
        if let imageData = UIImageJPEGRepresentation(currentImage, 0.2) {
            let imageUID = NSUUID().uuidString
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            DataService.ds.REF_POST_IMAGES.child(imageUID).putData(imageData, metadata: metadata, completion: { (metadata, error) in
                if error != nil {
                    print("Brennan - Error uploading image from new post to FB storage: \(error!.localizedDescription)")
                } else {
                    print("Brennan - Successfully uploaded image to FB storage.")
                    if let downloadURL = metadata?.downloadURL()?.absoluteString {
                        self.postToFirebase(imageURL: downloadURL, caption: caption)
                        print("Brennan - download URL is: \(downloadURL)")
                    } else {
                        print("Brennan - Couldn't get download URL from FB storage for some reason.")
                    }
                }
            })
        }
    }
    
    
    
    func postToFirebase(imageURL: String, caption: String) {
        
        // Reset posting UI to prepare for the next post.
        self.captionTextField.text = ""
        self.imageAddImageView.image = UIImage(named: "add-image")
        self.needsToAddImage = true
        self.view.endEditing(true)

        // Check to make sure we can get the current user's UID.
        guard let currUID = Auth.auth().currentUser?.uid else {
            print("Brennan - Unable to get the current user's UID for some reason.")
            return
        }
        
        // Dictionary of post data to push to Firebase:
        let postData: [String: Any] = [
            "caption": caption,
            "imageURL": imageURL,
            "likes": 0,
            "posterUID": currUID
        ]
        
        // Push the post data to Firebase.
        let newPostRef = DataService.ds.REF_POSTS.childByAutoId()
        newPostRef.updateChildValues(postData) { (error, ref) in
            if error != nil {
                print("Brennan - Error updating child values for new post in postToFirebase method: \(error!.localizedDescription)")
            } else {
                // Child values successfully updated. Make the post show up in UI.
                print("Brennan - Successfully uploaded post to Firebase.")
                
            }
        }
        
        // Add the post ID to the user's collection of posts in Firebase.
        let currUsersPostsRef = DataService.ds.REF_USERS.child("\(currUID)/posts")
        currUsersPostsRef.updateChildValues([newPostRef.key: true])
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    
    
    // Updates the feed once.
    func updateFeed() {
        DataService.ds.REF_POSTS.observeSingleEvent(of: .value, with: { (snapshot) in
            print("Brennan - Updating feed.")
            if let snaps = snapshot.children.allObjects as? [DataSnapshot] {
                self.posts.removeAll()
                for snap in snaps.reversed() {
                    if let postDict = snap.value as? [String: Any] {
                        let posterUID = postDict["posterUID"]! as! String
                        // Observer for retrieving poster's username and profile image URL.
                        DataService.ds.REF_USERS.child(posterUID).observeSingleEvent(of: .value, with: { (snapshot) in
                            if let posterDict = snapshot.value as? [String: Any] {
                                if let posterUsername = posterDict["username"] as? String, let posterProfileImageURL = posterDict["profileImageURL"] as? String {
                                    let post = Post(postID: snap.key, postData: postDict, posterUsername: posterUsername, posterProfileImageURL: posterProfileImageURL)
                                    self.posts.append(post)
                                    if self.posts.count == snaps.count {
                                        print("Brennan - Reloading table view data.")
                                        self.tableView.reloadData()
                                    }
                                }
                            }
                        })
                    }
                }
            }
        })
    }

    
    
    @IBAction func settingsButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "toAccountSettingsVC", sender: self)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toAccountSettingsVC", let settingsScreen = segue.destination as? AccountSettingsVC, let selfRef = sender as? FeedVC {
            settingsScreen.feedScreenRef = selfRef
        }
    }
    
    
    
    
    
    
    
}
