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

class BusinessVC: UIViewController {
    
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
//        let centerLocation = CLLocation(latitude: 37.7833, longitude: -122.4167)
//        goToLocation(location: centerLocation)
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = CLLocationDistance(searchFilters.distance ?? 200)
        locationManager.requestWhenInUseAuthorization()
        
        longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(mapRecognitionTapped))
        mapView.addGestureRecognizer(longPressRecognizer)
        
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
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let filtersVC = segue.destination as? FiltersVC else {return}
        filtersVC.delegate = self
        filtersVC.searchFilters = searchFilters
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






