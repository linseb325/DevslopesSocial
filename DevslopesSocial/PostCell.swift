//
//  PostCell.swift
//  DevslopesSocial
//
//  Created by Brennan Linse on 7/10/17.
//  Copyright © 2017 Brennan Linse. All rights reserved.
//

import UIKit
import Firebase

class PostCell: UITableViewCell {
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var captionTextView: UITextView!
    @IBOutlet weak var numLikesLabel: UILabel!
    
    var post: Post!
    
    func configureCell(post: Post, image: UIImage? = nil) {
        self.post = post
        self.captionTextView.text = post.caption
        self.numLikesLabel.text = "\(post.likes)"
        
        if let img = image {
            self.postImageView.image = img
        } else {
            let ref = Storage.storage().reference(forURL: post.imageURL)
            ref.getData(maxSize: 2 * 1024 * 1024, completion: { (data, error) in
                if error != nil {
                    print("Brennan - Unable to download image from Firebase storage: \(error!.localizedDescription)")
                } else {
                    print("Brennan - Downloaded image from Firebase storage.")
                    if let imageData = data {
                        if let img = UIImage(data: imageData) {
                            self.postImageView.image = img
                            FeedVC.imageCache.setObject(img, forKey: post.imageURL as NSString)
                        }
                    }
                }
                
                
            })
        }
        
    }
    
    
}
