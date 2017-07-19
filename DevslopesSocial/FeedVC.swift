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

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var posts = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        DataService.ds.REF_POSTS.observe(.value, with: { (snapshot) in
            if let snaps = snapshot.children.allObjects as? [DataSnapshot] {
                self.posts.removeAll()
                for snap in snaps {
                    print("Brennan - SNAPSHOT: \(snap)")
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
            cell.configureCell(post: post)
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
    
    
    
    
    
    
    
    
    
    
    
    
}
