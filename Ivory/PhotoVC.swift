//
//  PhotoVC.swift
//  Ivory
//
//  Created by James Dyer on 5/7/16.
//  Copyright © 2016 TripTrunk. All rights reserved.
//

import UIKit

class PhotoVC: UIViewController {

    @IBOutlet weak var imageView: UIView!
    @IBOutlet weak var stillImageView: UIImageView!
    
    var stillImage: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        stillImageView.image = stillImage
        view.sendSubviewToBack(imageView)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    @IBAction func cancelButtonPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func continueButtonPressed(sender: AnyObject) {
        
    }
    
}
