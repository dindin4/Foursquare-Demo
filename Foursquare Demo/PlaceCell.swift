//
//  PlaceCell.swift
//  Foursquare Demo
//
//  Created by Dinesh Vijaykumar on 10/09/2017.
//  Copyright © 2017 Dinesh Vijaykumar. All rights reserved.
//

import UIKit

class PlaceCell: UITableViewCell {

    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var placeImageView: UIImageView!
    @IBOutlet weak var ratingCell: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.ratingCell.layer.cornerRadius = self.ratingCell.bounds.width / 2
        self.ratingCell.layer.masksToBounds = true
        self.ratingCell.textColor  = UIColor.white
    }
    
    func configureCell(place:Place) {
        self.nameLabel.text = place.name
        self.ratingCell.text = String(place.rating)
        self.ratingCell.backgroundColor = place.ratingColor
        
        if let miles = place.distance {
            self.distanceLabel.text = "\(miles) miles"
        }
        
        self.categoryLabel.text = place.category
        
        
    }

   

}
