//
//  PhotoCell.swift
//  virtual-tourist
//
//  Created by Ricardo Hdz on 10/13/15.
//  Copyright © 2015 Ricardo Hdz. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    override var highlighted: Bool {
        didSet {
            if highlighted {
                self.layer.opacity = 0.5
            } else {
                self.layer.opacity = 1.0
            }
        }
    }
}
