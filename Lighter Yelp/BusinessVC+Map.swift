//
//  BusinessVC+Map.swift
//  Lighter Yelp
//
//  Created by user on 9/23/17.
//  Copyright © 2017 YSH. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation

extension BusinessVC: CLLocationManagerDelegate, MKMapViewDelegate {
    
    
    func viewBusinessesOnMap() {
        guard let businessesOnMap = businesses else {return}
        
        for business in businessesOnMap {
            if let address = business.address, let name = business.name {
                addAnnotationAtAddress(address: address, title: name)
            }
        }
    }
    
    func setupMapRegionAndSpan() {
        let location = CLLocation(latitude: 37.7833, longitude: -122.4167)
        
        var spanValue:Double!
        switch searchFilters.distance! {
        case Constants.DISTANCE[0]["code"] as! Int:
            spanValue = 0.05
        case Constants.DISTANCE[1]["code"] as! Int:
            spanValue = 0.1
        case Constants.DISTANCE[2]["code"] as! Int:
            spanValue = 0.2
        case Constants.DISTANCE[3]["code"] as! Int:
            spanValue = 0.5
        default:
            spanValue = 0.1
        }
        
        let spanView = MKCoordinateSpanMake(spanValue, spanValue)
        let region = MKCoordinateRegionMake(location.coordinate, spanView)
        mapView.setRegion(region, animated: true)
    }
    
    func getCoordinatesForLocation() {
        
        guard let location = locationBar.text else {return}
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(location) { [weak self] placemarks, error in
            if let placemark = placemarks?.first, let location = placemark.location {
                self?.searchFilters.location["lat"] = location.coordinate.latitude
                self?.searchFilters.location["lon"] = location.coordinate.longitude
                
                self?.doSearch()
                self?.viewBusinessesOnMap()
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
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let span = MKCoordinateSpanMake(0.1, 0.1)
            let region = MKCoordinateRegionMake(location.coordinate, span)
            mapView.setRegion(region, animated: false)
        }
    }
    
    func updateMapView() {
        
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
    
    // add an annotation with an address: String
    func addAnnotationAtAddress(address: String, title: String) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            if let placemarks = placemarks {
                if placemarks.count != 0 {
                    let coordinate = placemarks.first!.location!
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = coordinate.coordinate
                    annotation.title = title
                    self.mapView.addAnnotation(annotation)
                }
            }
        }
    }
    
    func removAllAnnotations(){
        
        self.mapView.annotations.forEach {
            if !($0 is MKUserLocation) {
                self.mapView.removeAnnotation($0)
            }
        }
    }
}
