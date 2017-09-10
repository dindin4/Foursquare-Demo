//
//  Place.swift
//  Foursquare Demo
//
//  Created by Dinesh Vijaykumar on 10/09/2017.
//  Copyright © 2017 Dinesh Vijaykumar. All rights reserved.
//

import UIKit
import CoreLocation

class Place: NSObject {
    var name: String!
    var rating: Double!
    var ratingColor: UIColor!
    var distance: Double!
    var imageUrl: String?
    var category: String!
    var location: CLLocationCoordinate2D!
    var contactNumber: String?
    
    init(name:String, rating: Double, ratingHexColor:String, distanceInMetres: Double, imageUrl: String?, category: String, locationLat: Double, locationLon: Double, telephone: String?) {
        self.name = name
        self.rating = rating
        self.ratingColor = UIColor(hex: ratingHexColor)
        self.imageUrl = imageUrl
        self.category = category
        
        let miles = 0.000621371
        let distanceInMiles = miles * distanceInMetres
        self.distance = distanceInMiles.rounded(toPlaces: 1)
        
        self.location = CLLocationCoordinate2D(latitude: locationLat, longitude: locationLon)
        self.contactNumber = telephone
    }

}

extension UIColor {
    convenience init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.scanLocation = 0
        
        var rgbValue: UInt64 = 0
        
        scanner.scanHexInt64(&rgbValue)
        
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        
        self.init(
            red: CGFloat(r) / 0xff,
            green: CGFloat(g) / 0xff,
            blue: CGFloat(b) / 0xff, alpha: 1
        )
    }
}

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
