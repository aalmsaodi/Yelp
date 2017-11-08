//
//  BusinessCell.swift
//  Lighter Yelp
//
//  Created by user on 9/18/17.
//  Copyright © 2017 YSH. All rights reserved.
//

import UIKit

class BusinessCell: UITableViewCell {
  
  @IBOutlet weak var thumbImageView: UIImageView!
  @IBOutlet weak var reviewImageView: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var addressLabel: UILabel!
  @IBOutlet weak var categoriesLabel: UILabel!
  @IBOutlet weak var distanceLabel: UILabel!
  @IBOutlet weak var numberReviewsLabel: UILabel!
  
  var business: Business! {
    didSet{
      nameLabel.text = business.name
      addressLabel.text = business.address
      categoriesLabel.text = business.categories
      distanceLabel.text = business.distance
      
      if let reviewNum = business.reviewNum {
        numberReviewsLabel.text = reviewNum  + " Reviews"
      }
      
      if let thumbURL = business.thumbImageURL {
        thumbImageView.setImageWith(thumbURL)
      }
      
      reviewImageView.setImageWith(business.ratingImageURL)
    }
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    thumbImageView.layer.cornerRadius = thumbImageView.frame.height/10
    thumbImageView.layer.masksToBounds = true
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
}
