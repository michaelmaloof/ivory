//
//  CustomButton.swift
//  Ivory
//
//  Created by James Dyer on 5/5/16.
//  Copyright © 2016 TripTrunk. All rights reserved.
//

import UIKit

class CustomButton: UIButton {

    override func awakeFromNib() {
        self.backgroundColor = UIColor.clearColor()
        layer.cornerRadius = 5
        layer.borderWidth = 1
        layer.borderColor = UIColor.blackColor().CGColor
    }

}
