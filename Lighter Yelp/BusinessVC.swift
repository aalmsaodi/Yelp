//
//  BusinessVC.swift
//  Lighter Yelp
//
//  Created by user on 9/18/17.
//  Copyright © 2017 YSH. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class BusinessVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var locationBar: UISearchBar!
    @IBOutlet weak var tableViewTopConstrain: NSLayoutConstraint!
    
    var businesses:[Business]!
    var searchFilters:Filters!
    var searchBar: UISearchBar!
    var offsetResults:Int = 20
    var isMoreDataLoading = false
    var loadingMoreView:InfiniteScrollActivityView?
    var locationManager : CLLocationManager!
    var longPressRecognizer:UILongPressGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
    
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        
        // Initialize the UISearchBar
        searchBar = UISearchBar()
        searchBar.delegate = self

        locationBar.delegate = self
        activateLocationBarCancelButton()
        
        // Add SearchBar to the NavigationBar
        searchBar.sizeToFit()
        navigationItem.titleView = searchBar
        
        let filterButton = UIBarButtonItem(image: UIImage(named:"filter"), style: .plain, target:self, action: #selector(goToFilters))
        navigationItem.leftBarButtonItem = filterButton
        
        let rightButton = UIBarButtonItem(image: UIImage(named:"map"), style: .plain, target:self, action: #selector(viewBusinessesStyle))
        navigationItem.rightBarButtonItem = rightButton
        
        searchFilters = Filters()
        
        doSearch()
        
        // Set up Infinite Scroll loading indicator
        let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.isHidden = true
        tableView.addSubview(loadingMoreView!)
        
        var insets = tableView.contentInset
        insets.bottom += InfiniteScrollActivityView.defaultHeight
        tableView.contentInset = insets
        
        // set starting center location in San Francisco
        let centerLocation = CLLocation(latitude: 37.7833, longitude: -122.4167)
        goToLocation(location: centerLocation)
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = CLLocationDistance(searchFilters.distance ?? 200)
        locationManager.requestWhenInUseAuthorization()
        
        longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(mapRecognitionTapped))
        mapView.addGestureRecognizer(longPressRecognizer)
        
    }
    
    func mapRecognitionTapped(_ sender: UILongPressGestureRecognizer) {
        let touchLocation = sender.location(in: mapView)
        let locationCoordinate = mapView.convert(touchLocation, toCoordinateFrom: mapView)
        
        let location = CLLocation(latitude: locationCoordinate.latitude, longitude: locationCoordinate.longitude)
        
        fetchCountryAndCity(location: location) { country, city in
            self.locationBar.text = "\(city), \(country)"
        }

    }

    func goToLocation(location: CLLocation) {
        let span = MKCoordinateSpanMake(0.1, 0.1)
        let region = MKCoordinateRegionMake(location.coordinate, span)
        mapView.setRegion(region, animated: false)
    }
    
    func goToFilters() {
        performSegue(withIdentifier: "toFilterSettingsVC" , sender: self)
    }
    
    func viewBusinessesStyle() {
        if navigationItem.rightBarButtonItem?.image == UIImage(named:"map") {
            mapView.isHidden = false
            viewBusinessesOnMap()
            navigationItem.rightBarButtonItem?.image = UIImage(named: "list")
        } else {
            mapView.isHidden = true
            navigationItem.rightBarButtonItem?.image = UIImage(named: "map")
        }
    }
    
    func viewBusinessesOnMap() {
        guard let businessesOnMap = businesses else {return}
        
//        let location = locationBar.text
//        let geocoder = CLGeocoder()
//        geocoder.geocodeAddressString(location ?? "San Francisco") { [weak self] placemarks, error in
//            if let placemark = placemarks?.first, let location = placemark.location {
//                let mark = MKPlacemark(placemark: placemark)
//                
//                if var region = self?.mapView.region {
//                    region.center = location.coordinate
//                    region.span.longitudeDelta /= 8.0
//                    region.span.latitudeDelta /= 8.0
//                    self?.mapView.setRegion(region, animated: true)
//                }
//            }
//        }
//        
        for business in businessesOnMap {
            if let address = business.address, let name = business.name {
                addAnnotationAtAddress(address: address, title: name)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if businesses != nil {
            return businesses.count
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "businessCell", for: indexPath) as! BusinessCell
        
        cell.business = businesses[indexPath.row]
        
        return cell
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let filtersVC = segue.destination as? FiltersVC else {return}
        filtersVC.delegate = self
        filtersVC.searchFilters = searchFilters
    }
}

extension BusinessVC: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.isDragging) {
                isMoreDataLoading = true
                
                // Update position of loadingMoreView, and start loading indicator
                let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()
                
                getMoreResults()
            }
        }
    }
    
    fileprivate func getMoreResults() {
        
        removAllAnnotations()
        Business.searchWithTerm(offsetBusinessesResutls: offsetResults, filters: searchFilters, completion: { (businesses: [Business]?, error: Error?) -> Void in
            
            guard let resultBusinesses = businesses else {return}
            
            for business in resultBusinesses {
                self.businesses.append(business)
            }
            
            self.offsetResults += 20
            
            if error != nil {
                print (error ?? "an Error in the HTTP Req")
            }
            
            self.isMoreDataLoading = false
            self.loadingMoreView!.stopAnimating()
            self.tableView.reloadData()
        })
    }
}

extension BusinessVC: FiltersVCDelegate {
    func dataReceived(filtersVC: FiltersVC, searchFilters: Filters) {
        self.searchFilters = searchFilters
    }
    
    func triggerSearch(filtersVC: FiltersVC) {
            doSearch()
            viewBusinessesOnMap()
    }
}






