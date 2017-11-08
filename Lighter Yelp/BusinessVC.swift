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
import SVProgressHUD

class BusinessVC: UIViewController {
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var currentLocationBtn: UIButton!
  @IBOutlet weak var locationBar: UISearchBar!
  @IBOutlet weak var tableViewTopConstrain: NSLayoutConstraint!
  
  var businesses:[Business]?
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
    
    searchBar = UISearchBar()
    searchBar.delegate = self
    searchBar.sizeToFit()
    navigationItem.titleView = searchBar
    
    locationBar.delegate = self
    activateLocationBarCancelButton()
    
    let filterButton = UIBarButtonItem(image: UIImage(named:"filter"), style: .plain, target:self, action: #selector(goToFiltersVC))
    navigationItem.leftBarButtonItem = filterButton
    
    let rightButton = UIBarButtonItem(image: UIImage(named:"map"), style: .plain, target:self, action: #selector(viewBusinessesStyle))
    navigationItem.rightBarButtonItem = rightButton
    
    searchFilters = Filters()
    
    let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
    loadingMoreView = InfiniteScrollActivityView(frame: frame)
    loadingMoreView!.isHidden = true
    tableView.addSubview(loadingMoreView!)
    var insets = tableView.contentInset
    insets.bottom += InfiniteScrollActivityView.defaultHeight
    tableView.contentInset = insets
    
    mapView.delegate = self
    locationManager = CLLocationManager()
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    locationManager.distanceFilter = CLLocationDistance(searchFilters.distance ?? 200)
    locationManager.requestWhenInUseAuthorization()
    currentLocationBtn.addTarget(self, action: #selector(goOnMapToCurrentLocation), for: UIControlEvents.touchUpInside)
    longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(mapRecognitionTapped))
    mapView.addGestureRecognizer(longPressRecognizer)
  }
  
  func goToFiltersVC() {
    performSegue(withIdentifier: "toFiltersVC" , sender: self)
  }
  
  func viewBusinessesStyle() {
    if navigationItem.rightBarButtonItem?.image == UIImage(named:"map") {
      mapView.isHidden = false
      currentLocationBtn.isHidden = false
      viewBusinessesOnMap()
      navigationItem.rightBarButtonItem?.image = UIImage(named: "list")
    } else {
      mapView.isHidden = true
      currentLocationBtn.isHidden = true
      navigationItem.rightBarButtonItem?.image = UIImage(named: "map")
    }
  }
  
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
    if segue.identifier == "toFiltersVC" {
      guard let filtersVC = segue.destination as? FiltersVC else {return}
      filtersVC.delegate = self
      filtersVC.searchFilters = searchFilters
      
    } else if segue.identifier == "fromMapToDetailsVC" {
      guard let detailsVC = segue.destination as? DetailsVC else {return}
      if let mapAnnotation = sender as? MKAnnotation {
        let index = Int(mapAnnotation.title!!)
        detailsVC.business = businesses?[index!]
      }
      
    } else if segue.identifier == "fromCellToDetailsVC" {
      guard let detailsVC = segue.destination as? DetailsVC else {return}
      if let cell = sender as? BusinessCell {
        let index = tableView.indexPath(for: cell)?.row
        detailsVC.business = businesses?[index!]
      }
    }
  }
}


extension BusinessVC: FiltersVCDelegate {
  func dataReceived(filtersVC: FiltersVC, searchFilters: Filters) {
    self.searchFilters = searchFilters
  }
  
  func triggerSearch(filtersVC: FiltersVC) {
    doSearch()
  }
}

// MARK: - UISearchBar Delegate *******************************************************************
extension BusinessVC: UISearchBarDelegate {
  
  func doSearch() {
    
    SVProgressHUD.show()
    removAllAnnotations()
    
    Business.searchWithTerm(offsetBusinessesResutls: 0, filters: searchFilters, completion: { (businesses: [Business]?, error: Error?) -> Void in
      guard let businessesResponse = businesses else {return}
      self.businesses = businessesResponse
      
      if error != nil {
        print (error ?? "an Error in the HTTP Req")
      }
      
      SVProgressHUD.dismiss()
      self.setupMapRegionAndSpan()
      self.viewBusinessesOnMap()
      self.tableView.reloadData()
    })
  }
  
  
  func searchBarShouldBeginEditing(_ sBar: UISearchBar) -> Bool {
    showLocationBar()
    locationBar.setShowsCancelButton(true, animated: true)
    return true
  }
  
  
  func searchBarSearchButtonClicked(_ sBar: UISearchBar) {
    guard let inputText = sBar.text else {return}
    
    if let term = searchBar.text {
      searchFilters.searchTerm = term
    }
    
    //setting location and searching if event come from location bar
    if sBar == locationBar {
      if inputText.lowercased() == "current location" {
        locationManager.startUpdatingLocation()
      } else {
        setSearchLocationCoordinates()
      }
    }
    
    //searching only if event comes from search bar
    if sBar == searchBar {
      doSearch()
    }
    
    sBar.resignFirstResponder()
    hideLocationBar()
  }
  
  func searchBarCancelButtonClicked(_ sBar: UISearchBar) {
    searchBar.text = ""
    searchBar.resignFirstResponder()
    locationBar.resignFirstResponder()
    hideLocationBar()
  }
  
  
  // MARK: Search helping functions
  func hideLocationBar() {
    locationBar.isHidden = true
    tableViewTopConstrain.constant = 0
    UIView.animate(withDuration: 0.5) {
      self.view.layoutIfNeeded()
    }
  }
  
  func showLocationBar() {
    locationBar.isHidden = false
    tableViewTopConstrain.constant = locationBar.bounds.size.height
    UIView.animate(withDuration: 0.5) {
      self.view.layoutIfNeeded()
    }
  }
  
  func activateLocationBarCancelButton() {
    for view in locationBar.subviews {
      for subview in view.subviews {
        if let button = subview as? UIButton {
          button.isEnabled = true
        }
      }
    }
  }
}

// MARK: - CLLocationManager & MKMapView Delegates ******************************************************
extension BusinessVC: CLLocationManagerDelegate, MKMapViewDelegate {
  
  func viewBusinessesOnMap() {
    guard let businessesOnMap = businesses else {return}
    
    for (i,business) in businessesOnMap.enumerated() {
      addAnnotationAtCoordinate(coordinates: business.coordinate, index: i)
    }
  }
  
  func setupMapRegionAndSpan() {
    let location = CLLocation(latitude: searchFilters.location["lat"]!, longitude: searchFilters.location["lon"]!)
    
    var spanValue:Double!
    switch searchFilters.distance! {
    case Constants.DISTANCE[0]["code"] as! Int:
      spanValue = 0.03
    case Constants.DISTANCE[1]["code"] as! Int:
      spanValue = 0.07
    case Constants.DISTANCE[2]["code"] as! Int:
      spanValue = 0.1
    case Constants.DISTANCE[3]["code"] as! Int:
      spanValue = 0.2
    default:
      spanValue = 0.1
    }
    
    let spanView = MKCoordinateSpanMake(spanValue, spanValue)
    let region = MKCoordinateRegionMake(location.coordinate, spanView)
    mapView.setRegion(region, animated: true)
  }
  
  func setSearchLocationCoordinates() {
    guard let location = locationBar.text else {return}
    let geocoder = CLGeocoder()
    geocoder.geocodeAddressString(location) { [weak self] placemarks, error in
      if let placemark = placemarks?.first, let location = placemark.location {
        self?.searchFilters.location["lat"] = location.coordinate.latitude
        self?.searchFilters.location["lon"] = location.coordinate.longitude
        
        self?.doSearch()
      }
    }
    
  }
  
  func mapRecognitionTapped(_ sender: UILongPressGestureRecognizer) {
    let touchLocation = sender.location(in: mapView)
    let locationCoordinate = mapView.convert(touchLocation, toCoordinateFrom: mapView)
    
    let location = CLLocation(latitude: locationCoordinate.latitude, longitude: locationCoordinate.longitude)
    
    fetchCountryAndCity(location: location) { country, city in
      self.locationBar.text = "\(city), \(country)"
    }
    
  }
  
  func fetchCountryAndCity(location: CLLocation, completion: @escaping (String, String) -> ()) {
    CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
      if let error = error {
        print(error)
      } else if let country = placemarks?.first?.country,
        let city = placemarks?.first?.locality {
        completion(country, city)
      }
    }
  }
  
  
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    if status == CLAuthorizationStatus.authorizedWhenInUse {
      locationManager.startUpdatingLocation()
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    let locValue:CLLocationCoordinate2D = manager.location!.coordinate
    searchFilters.location = ["lat": locValue.latitude, "lon": locValue.longitude]
    
    doSearch()
  }
  
  func addAnnotationAtCoordinate(coordinates:[String:Double], index:Int) {
    let annotation = MKPointAnnotation()
    annotation.coordinate = CLLocationCoordinate2D(latitude: coordinates["lat"]!, longitude: coordinates["lon"]!)
    mapView.addAnnotation(annotation)
    annotation.title = "\(index)"
    self.mapView.addAnnotation(annotation)
  }
  
  func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
    if (view.annotation?.title)!?.lowercased() != "current location" {
      performSegue(withIdentifier: "fromMapToDetailsVC", sender: view.annotation)
    }
    //To hide title, and just use it as an index element
    mapView.deselectAnnotation(view.annotation, animated: true)
  }
  
  func goOnMapToCurrentLocation()  {
    locationManager.startUpdatingLocation()
    locationBar.text = "Current Location"
  }
  
  func removAllAnnotations(){
    self.mapView.annotations.forEach {
      if !($0 is MKUserLocation) {
        self.mapView.removeAnnotation($0)
      }
    }
  }
}

// MARK: - UIScrollView Delegate ********************************************************************
extension BusinessVC: UIScrollViewDelegate {
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if (!isMoreDataLoading) {
      let scrollViewContentHeight = tableView.contentSize.height
      let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
      
      if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.isDragging) {
        isMoreDataLoading = true
        
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
        self.businesses?.append(business)
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

// MARK: - UITableView Delegate ********************************************************************
extension BusinessVC: UITableViewDelegate, UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if businesses != nil {
      return businesses!.count
    } else {
      return 0
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "businessCell", for: indexPath) as! BusinessCell
    cell.business = businesses?[indexPath.row]
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let cell = tableView.cellForRow(at: indexPath)
    performSegue(withIdentifier: "fromCellToDetailsVC", sender: cell)
  }
}







