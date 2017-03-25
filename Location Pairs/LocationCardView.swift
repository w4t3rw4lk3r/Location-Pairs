//
//  LocationCardView.swift
//  Location Pairs
//
//  Created by Joshua Areogun on 25/03/2017.
//  Copyright © 2017 Joshua Areogun. All rights reserved.
//

import UIKit

class LocationCardView: UICollectionViewCell {

    @IBOutlet weak var locationImageView: UIImageView!
    @IBOutlet weak var coverView: UIView!
    override func awakeFromNib() {

        // reveal all initially
        coverView.isHidden = true

        let dispatchGroup = DispatchGroup()

        dispatchGroup.enter()
        // hide images after a delay
        let delayInSeconds = DispatchTime.now() + 1
        DispatchQueue.main.asyncAfter(deadline: delayInSeconds) {
            self.coverView.isHidden = false
            dispatchGroup.leave()
        }

        dispatchGroup.notify(queue: .main, execute: {
            let blankImage:UIImage = UIImage(named: "white.png")!
            if (self.locationImageView.image?.isEqual(blankImage))! {
                self.coverView.isHidden = true
            }
        })
    }
}
