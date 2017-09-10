//
//  PlacesTableViewController.swift
//  Foursquare Demo
//
//  Created by Dinesh Vijaykumar on 10/09/2017.
//  Copyright © 2017 Dinesh Vijaykumar. All rights reserved.
//

import UIKit
import CoreLocation

class PlacesTableViewController: UITableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var filterButton: UIBarButtonItem!
    
    var places:[Place] = []
    var cache:NSCache<AnyObject, AnyObject>!
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.barTintColor = UIColor(red: 0.0, green: 0.64, blue: 0.93, alpha: 1)
        searchBar.delegate = self
        searchBar.returnKeyType = UIReturnKeyType.done
        
        self.cache = NSCache()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.filterButton.isEnabled = places.count > 1
        
        return places.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "placeCell", for: indexPath) as! PlaceCell
        let place = self.places[indexPath.row]
        
        // Configure the cell...
        cell.configureCell(place: place)
        
        cell.placeImageView.image = nil
        
        if let image = self.cache.object(forKey: indexPath.row as AnyObject) as? UIImage {
            cell.placeImageView.image = image
        } else {
            if let imageUrl = place.imageUrl, let url = URL(string: imageUrl) {
                URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                    guard let data = data else {
                        print("Error: No data")
                        return
                    }
                    
                    if error !=  nil {
                        print("Error: \(error.debugDescription)")
                    } else {
                        DispatchQueue.main.async {
                            if let _ = tableView.cellForRow(at: indexPath), let downloadedImage = UIImage(data: data) {
                                cell.placeImageView.image = downloadedImage
                                self.cache.setObject(downloadedImage, forKey: indexPath.row as AnyObject)
                            }
                        }
                    }
                }).resume()
            }
        }
        if cell.placeImageView.image == nil {
            cell.placeImageView.image = UIImage(named: "placeholder")
        }
        
        return cell
    }
    
    // MARK: - Fetching
    
    func fetchPlaces(query: String) {
        
        guard let location = self.currentLocation else {
            let alertController = UIAlertController(title: "Cannot find current location", message: "Try again later", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        places.removeAll()
        
        let endpointUrl = "https://api.foursquare.com/v2/venues/explore?ll=\(location.coordinate.latitude),\(location.coordinate.longitude)&query=\(query)&venuePhotos=1&oauth_token=RURLG2J5JPYY2W5NCHKQY1NLNCJCIS4D50FID0QADDXG1VPW&v=20170909"
        
        guard let endpoint = URL(string: endpointUrl) else {
            print("Cannot create endpoint")
            return
        }
        
        URLSession.shared.dataTask(with: endpoint) { (data, response, error) in
            do {
                guard let data = data else {
                    print("Error: No data")
                    return
                }
                
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                    if let response = json["response"] as? NSDictionary, let groups = response["groups"] as? [NSDictionary] {
                        if let items = groups.first?["items"] as? [NSDictionary] {
                            for item in items {
                                if let venue = item["venue"] as? NSDictionary {
                                    var name = ""
                                    var ratingHexColour = ""
                                    var imageUrl: String? = nil
                                    var category = ""
                                    var phone: String? = nil
                                    var rating: Double = 0
                                    var distance: Double = 0
                                    var lat: Double = 0
                                    var lon: Double = 0
                                    
                                    if let placeName = venue["name"] as? String {
                                        name = placeName
                                    }
                                    
                                    if let placeRating = venue["rating"] as? Double {
                                        rating = placeRating
                                    }
                                    
                                    if let ratingColour = venue["ratingColor"] as? String {
                                        ratingHexColour = ratingColour
                                    }
                                    
                                    if let location = venue["location"] as? NSDictionary, let distanceInMetres = location["distance"] as? Double, let locationLat = location["lat"] as? Double, let locationLon = location["lng"] as? Double {
                                        distance = distanceInMetres
                                        lat = locationLat
                                        lon = locationLon
                                    }
                                    
                                    if let categories = venue["categories"] as? [NSDictionary], categories.count > 0 {
                                        let categoryDict = categories[0]
                                        if let categoryName = categoryDict["name"] as? String {
                                            category = categoryName
                                        }
                                    }
                                    
                                    if let photos = venue["photos"] as? NSDictionary, let photoGroups = photos["groups"] as? [NSDictionary], photoGroups.count > 0 {
                                        if let photoGroupItems = photoGroups[0]["items"] as? [NSDictionary] {
                                            imageUrl = self.constructImageUrl(photoItem: photoGroupItems.first)
                                        }
                                    }
                                    
                                    if let contactDetails = venue["contact"] as? NSDictionary, let phoneNumber = contactDetails["phone"] as? String {
                                        phone = phoneNumber
                                    }
                                    
                                    let place = Place(name: name, rating: rating, ratingHexColor: ratingHexColour, distanceInMetres: distance, imageUrl: imageUrl, category: category, locationLat: lat,locationLon: lon, telephone: phone)
                                    self.places.append(place)
                                    
                                }
                            }
                        }
                    }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                } else {
                    print("Error: JSON Conversion Failed")
                    return
                }
            } catch {
                print(error)
            }
            }.resume()
    }
    
    func constructImageUrl(photoItem: NSDictionary?) -> String? {
        if let item = photoItem {
            if let prefix = item["prefix"] as? String, let suffix = item["suffix"] as? String {
                return "\(prefix)50x50\(suffix)"
            }
        }
        
        return nil
    }
    
    
    // MARK: - IBActions
    @IBAction func filterResults(_ sender: Any) {
        let alertController = UIAlertController(title: "Sort by", message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let distanceAction = UIAlertAction(title: "Distance", style: .default) { (action) in
            self.places.sort(by: { (placeA, placeB) -> Bool in
                return placeA.distance < placeB.distance
            })
            self.tableView.reloadData()
        }
        let ratingButton = UIAlertAction(title: "Rating", style: .default) { (action) in
            self.places.sort(by: { (placeA, placeB) -> Bool in
                return placeA.rating > placeB.rating
            })
            self.tableView.reloadData()
        }
        
        alertController.addAction(distanceAction)
        alertController.addAction(ratingButton)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
}


// MARK: - UISearchbar delegate
extension PlacesTableViewController: UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
        
        guard let query = searchBar.text, !query.isEmpty else {
            return
        }
        
        let trimmedString = query.trimmingCharacters(in: .whitespacesAndNewlines)
        let encodedQuery = trimmedString.components(separatedBy: " ").filter {
            !$0.isEmpty
            }.joined(separator: "+")
        
        self.fetchPlaces(query: encodedQuery)
    }
}

extension PlacesTableViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("didFailWithError: \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let latestLocation = locations.last {
            self.currentLocation = latestLocation
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        case .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
            break
        case .denied:
            // user denied your app access to Location Services, but can grant access from Settings.app
            let alertController = UIAlertController(title: "Location Services Access Denied", message: "Access to location services has been turned off. Enable them from the settings app to allow location to be accessed", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let settingsAction = UIAlertAction(title: "Settings", style: .default, handler: { (action) in
                if let url = URL(string: UIApplicationOpenSettingsURLString) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            })
            alertController.addAction(settingsAction)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
            break
        default:
            break
        }
    }
}
