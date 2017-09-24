//
//  DetailsVC+Map.swift
//  Lighter Yelp
//
//  Created by user on 9/24/17.
//  Copyright © 2017 YSH. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation

extension DetailsVC: CLLocationManagerDelegate, MKMapViewDelegate {
    
    func setupMapRegionAndSpan() {
        let location = CLLocation(latitude: business.coordinate["lat"]!, longitude: business.coordinate["lon"]!)
        
        let spanView = MKCoordinateSpanMake(0.03, 0.03)
        let region = MKCoordinateRegionMake(location.coordinate, spanView)
        mapView.setRegion(region, animated: true)
    }
    
    func addAnnotationAtCoordinate() {
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: business.coordinate["lat"]!, longitude: business.coordinate["lon"]!)
        mapView.addAnnotation(annotation)
        self.mapView.addAnnotation(annotation)
    }
}
