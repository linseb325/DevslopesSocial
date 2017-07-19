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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell")
        if let c = cell {
            return c
        }
        print("Didn't dequeue a PostCell table view cell for some reason")
        return UITableViewCell()
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
