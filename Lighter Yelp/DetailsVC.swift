//
//  DetailsVC.swift
//  Lighter Yelp
//
//  Created by user on 9/23/17.
//  Copyright © 2017 YSH. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class DetailsVC: UIViewController {
  
  @IBOutlet weak var thumbImage: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var snippetLabel: UILabel!
  @IBOutlet weak var addressLabel: UILabel!
  @IBOutlet weak var reviewImage: UIImageView!
  @IBOutlet weak var categoriesLabel: UILabel!
  @IBOutlet weak var numOfReviewsLabel: UILabel!
  @IBOutlet weak var mapView: MKMapView!
  
  var business:Business!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    nameLabel.text = business.name
    addressLabel.text = business.address
    numOfReviewsLabel.text = business.reviewNum
    reviewImage.setImageWith(business.ratingImageURL)

    if let thumbURL = business.thumbImageURL {
      thumbImage.setImageWith(thumbURL)
    }
    
    if let snip = business.snippet {
      snippetLabel.text = snip
    }
    
    if let categ = business.categories {
      categoriesLabel.text = categ
    }
    
    setupMapRegionAndSpan()
    addAnnotationAtCoordinate()
  }
  
  @IBAction func callBtnTapped(_ sender: Any) {
    guard let num = business.phone else {return}
    guard let urlNum = URL(string: ("tel://\(num)")) else { return }
    UIApplication.shared.open(urlNum)
  }
}

// MARK: - CLLocationManager & MKMapView Delegates ******************************************************
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
