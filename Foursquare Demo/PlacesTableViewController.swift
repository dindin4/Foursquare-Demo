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
        
        let place = Place(name: "Goals", rating: 9.0, ratingHexColor: "73CF42", distanceInMetres: 784, imageUrl: "https://irs0.4sqi.net/img/general/50x50/2341723_vt1Kr-SfmRmdge-M7b4KNgX2_PHElyVbYL65pMnxEQw.jpg", category: "Movie Theatre")
        places = [place]
        self.cache = NSCache()
        filterButton.isEnabled = false
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
    
    @IBAction func filterResults(_ sender: Any) {
        print("Filter Pressed")
    }
    
    
}
