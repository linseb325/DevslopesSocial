//
//  FancyView.swift
//  DevslopesSocial
//
//  Created by Brennan Linse on 6/25/17.
//  Copyright © 2017 Brennan Linse. All rights reserved.
//

import UIKit

class FancyView: UIView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.shadowColor = UIColor(red: SHADOW_GRAY, green: SHADOW_GRAY, blue: SHADOW_GRAY, alpha: SHADOW_GRAY).cgColor
        layer.shadowOpacity = 0.0
        layer.shadowRadius = 5.0
        layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
    }
}
