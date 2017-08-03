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
    @IBOutlet weak var likeImageView: UIImageView!
    
    var post: Post!
    let currUserLikesRef = DataService.ds.REF_CURRENT_USER.child("likes")
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(likeTapped))
        tap.numberOfTapsRequired = 1    // Default is 1; this line not necessarily required
        self.likeImageView.addGestureRecognizer(tap)
        self.likeImageView.isUserInteractionEnabled = true
    }
    
    
    
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
                    if let imageData = data {
                        if let img = UIImage(data: imageData) {
                            self.postImageView.image = img
                            FeedVC.imageCache.setObject(img, forKey: post.imageURL as NSString)
                        }
                    }
                }
            })
        }
        
        self.currUserLikesRef.child(post.postID).observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                // The user hasn't liked this post.
                self.likeImageView.image = UIImage(named: "empty-heart")
            } else {
                // The user has liked this post.
                print("Brennan - Current user likes this")
                self.likeImageView.image = UIImage(named: "filled-heart")
            }
        })
    }
    
    
    
    func likeTapped(sender: UITapGestureRecognizer) {
        self.currUserLikesRef.child(post.postID).observeSingleEvent(of: .value, with: { (snapshot) in
            print("LIKE TAPPED SNAPSHOT: \(snapshot)")
            if let _ = snapshot.value as? NSNull {
                self.likeImageView.image = UIImage(named: "filled-heart")
                // Update number of likes in the post object and Firebase
                self.post.adjustLikes(addLike: true)
                // Add the post ID to the current user's list of likes in Firebase
                self.currUserLikesRef.updateChildValues([self.post.postID: true])
            } else {
                self.likeImageView.image = UIImage(named: "empty-heart")
                // Update number of likes in the post object and Firebase
                self.post.adjustLikes(addLike: false)
                // Remove the post ID from the current user's list of likes in Firebase
                self.currUserLikesRef.child(self.post.postID).removeValue()
            }
        })
    }
    
    
    
    
    
    
    
}
