//
//  PostCell.swift
//  DevslopesSocial
//
//  Created by Brennan Linse on 7/10/17.
//  Copyright © 2017 Brennan Linse. All rights reserved.
//

import UIKit

class PostCell: UITableViewCell {
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var captionTextView: UITextView!
    @IBOutlet weak var numLikesLabel: UILabel!
    
    var post: Post!
    
    func configureCell(post: Post) {
        self.post = post
        self.captionTextView.text = post.caption
        self.numLikesLabel.text = "\(post.likes)"
        
        /*
        let imgURL = URL(string: post.imageURL)!
        do {
            let data = try Data(contentsOf: imgURL)
            if let image = UIImage(data: data) {
                self.postImageView.image = image
            }
        } catch {
            print("Brennan - Error in configureCell method of PostCell class: \(error.localizedDescription)")
        }
        */
    }
    
    
}
