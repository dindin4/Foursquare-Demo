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

    override func viewDidLoad() {
        super.viewDidLoad()

        let place = Place(name: "Goals", rating: 9.0, ratingHexColor: "73CF42", distanceInMetres: 784, imageUrl: "https://igx.4sqi.net/img/general/27403276_nm4GBboL24GKXNnu-SaejIs4VHw380vsHjK3J-1Npn4.jpg", category: "Movie Theatre")
        places = [place]
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

        return cell
    }

    @IBAction func filterResults(_ sender: Any) {
        print("Filter Pressed")
    }


}
