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

