//
//  RoundImageView.swift
//  DevslopesSocial
//
//  Created by Brennan Linse on 6/28/17.
//  Copyright © 2017 Brennan Linse. All rights reserved.
//

import UIKit

class RoundImageView: UIImageView {
    
    override func layoutSubviews() {
        layer.cornerRadius = self.frame.width / 2
        clipsToBounds = true
    }
}
