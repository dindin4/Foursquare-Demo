//
//  RouteViewController.swift
//  Foursquare Demo
//
//  Created by Dinesh Vijaykumar on 10/09/2017.
//  Copyright © 2017 Dinesh Vijaykumar. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class RouteViewController: UIViewController {
    
    var destination: MKMapItem?
    @IBOutlet weak var routeMap: MKMapView!
    var locationManager: CLLocationManager = CLLocationManager()
    var userLocation: CLLocation?
    var place: Place?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let place = place {
            self.title = place.name
            let destinationPlacemark = MKPlacemark(coordinate: place.location, addressDictionary: nil)
            self.destination = MKMapItem(placemark: destinationPlacemark)
            
            if place.contactNumber != nil {
                 navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Contact", style: .plain, target: self, action: #selector(callNumber))
            }
        }
        
        routeMap.delegate = self
        routeMap.showsUserLocation = true
        routeMap.userTrackingMode = .follow
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestLocation()
    }
    
    func getDirections() {
        
        let request = MKDirectionsRequest()
        request.source = MKMapItem.forCurrentLocation()
        request.destination = destination!
        request.transportType = .walking
        request.requestsAlternateRoutes = false
        
        let directions = MKDirections(request: request)
        
        directions.calculate(completionHandler: {(response, error) in
            
            if error != nil {
                print("Error getting directions")
            } else {
                self.showRoute(response!)
            }
        })
    }
    
    func showRoute(_ response: MKDirectionsResponse) {
        
        for route in response.routes {
            routeMap.add(route.polyline, level: MKOverlayLevel.aboveRoads)
        }
        
        if let locationCoord = userLocation?.coordinate {
            let viewRegion = MKCoordinateRegionMakeWithDistance(locationCoord, 500, 500)
            routeMap.setRegion(viewRegion, animated: false)
        }
    }
    
    func callNumber(sender: UIBarButtonItem) {
        guard let number = self.place?.contactNumber, let url = URL(string: "tel://" + number) else {
            return
        }
        
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
}

extension RouteViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations[0]
        self.getDirections()
        self.locationManager.stopUpdatingLocation()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}

extension RouteViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 5.0
        return renderer
    }
    
}
