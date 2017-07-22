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

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

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
        
        DataService.ds.REF_POSTS.observe(.value, with: { (snapshot) in
            if let snaps = snapshot.children.allObjects as? [DataSnapshot] {
                self.posts.removeAll()
                for snap in snaps {
                    print("Brennan - SNAPSHOT from observer: \(snap)")
                    if let postDict = snap.value as? Dictionary<String, Any> {
                        let post = Post(postID: snap.key, postData: postDict)
                        self.posts.append(post)
                    }
                }
            }
            self.tableView.reloadData()
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
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as? PostCell {
            if let imageFromCache = FeedVC.imageCache.object(forKey: post.imageURL as NSString) {
                print("Brennan - Found image in cache with URL: \(post.imageURL)")
                cell.configureCell(post: post, image: imageFromCache)
            } else {
                cell.configureCell(post: post)
            }
            return cell
        } else {
            print("Brennan - Didn't dequeue a reusable PostCell for some reason. Returning a generic PostCell.")
            return PostCell()
        }
    }
    
    
    @IBAction func signOutPressed(_ sender: Any) {
        print("Brennan - Got into signOutPressed")
        
        let didRemoveFromKeychain = KeychainWrapper.standard.removeObject(forKey: KEY_UID)
        print("Brennan - Did remove UID from keychain? -> \(didRemoveFromKeychain)")
        
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
                        // Do something with the download URL.
                        print("Brennan - download URL is: \(downloadURL)")
                    } else {
                        print("Brennan - Couldn't get download URL from FB storage for some reason.")
                    }
                }
            })
        }
        
    }
    
    
    
    
    
    
    
    
}
