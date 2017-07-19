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
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}
