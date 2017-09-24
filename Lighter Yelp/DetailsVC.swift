//
//  DetailsVC.swift
//  Lighter Yelp
//
//  Created by user on 9/23/17.
//  Copyright © 2017 YSH. All rights reserved.
//

import UIKit
import MapKit

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

        if let name = business.name {
            nameLabel.text = name
        }
        
        if let address = business.address {
            addressLabel.text = address
        }
        
        if let numReviews = business.reviewNum {
            numOfReviewsLabel.text = String(describing: numReviews)
        }
        
        if let thumbURL = business.thumbImageURL {
            thumbImage.setImageWith(thumbURL)
        }
        
        if let ratingURL = business.ratingImageURL {
            reviewImage.setImageWith(ratingURL)
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
