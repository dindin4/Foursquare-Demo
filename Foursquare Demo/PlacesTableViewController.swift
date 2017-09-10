//
//  PlacesTableViewController.swift
//  Foursquare Demo
//
//  Created by Dinesh Vijaykumar on 10/09/2017.
//  Copyright © 2017 Dinesh Vijaykumar. All rights reserved.
//

import UIKit

class PlacesTableViewController: UITableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var filterButton: UIBarButtonItem!
    var places:[Place] = []
    var cache:NSCache<AnyObject, AnyObject>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        searchBar.returnKeyType = UIReturnKeyType.done
        filterButton.isEnabled = false

        self.cache = NSCache()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "placeCell", for: indexPath) as! PlaceCell
        let place = self.places[indexPath.row]
        
        // Configure the cell...
        cell.configureCell(place: place)
        
        cell.placeImageView.image = UIImage(named: "placeholder")
        
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
        return cell
    }
    
    // MARK: - Fetching
    
    func fetchPlaces(query: String) {
        places.removeAll()
        let endpointUrl = "https://api.foursquare.com/v2/venues/explore?ll=51.5007325,-0.1268194&query=\(query)&venuePhotos=1&oauth_token=RURLG2J5JPYY2W5NCHKQY1NLNCJCIS4D50FID0QADDXG1VPW&v=20170909"
        
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
                                    var imageUrl: String? = ""
                                    var category = ""
                                    var rating: Double = 0
                                    var distance: Double = 0
                                    
                                    if let placeName = venue["name"] as? String {
                                        name = placeName
                                    }
                                    
                                    if let placeRating = venue["rating"] as? Double {
                                        rating = placeRating
                                    }
                                    
                                    if let ratingColour = venue["ratingColor"] as? String {
                                        ratingHexColour = ratingColour
                                    }
                                    
                                    if let location = venue["location"] as? NSDictionary, let distanceInMetres = location["distance"] as? Double {
                                        distance = distanceInMetres
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
                                    let place = Place(name: name, rating: rating, ratingHexColor: ratingHexColour, distanceInMetres: distance, imageUrl: imageUrl, category: category)
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
        print("Filter Pressed")
    }
}


   // MARK: - UISearchbar delegate
extension PlacesTableViewController: UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
        
        guard let query = searchBar.text, !query.isEmpty else {
            return
        }
        self.fetchPlaces(query: query)
    }
}
