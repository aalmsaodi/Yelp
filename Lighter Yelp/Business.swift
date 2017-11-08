//
//  Business.swift
//  Lighter Yelp
//
//  Created by user on 9/18/17.
//  Copyright © 2017 YSH. All rights reserved.
//

import UIKit
import SwiftyJSON

class Business {
  
  let name: String
  var address: String?
  let coordinate: [String:Double]
  let ratingImageURL: URL
  let reviewNum: String?
  let phone:String?
  let snippet:String?
  let thumbImageURL: URL?
  let categories: String?
  let distance: String?

  
  init(dictionary: JSON) {
    self.name = dictionary["name"].string!
    
    let location = dictionary["location"].dictionary!
    if let address = location["address"]?.array?.first?.string {
      if let neighborhood = location["neighborhoods"]?.array?.first?.string {
        self.address = address + ", " + neighborhood
      }
    } else {
      self.address = nil
    }

    let lat = location["coordinate"]?["latitude"].double!
    let lon = location["coordinate"]?["longitude"].double!
    self.coordinate = ["lat": lat!, "lon": lon!]
    
    let ratingImageURLString = dictionary["rating_img_url_large"].string!
    self.ratingImageURL = URL(string: ratingImageURLString)!
    
    self.phone = dictionary["phone"].string
    self.snippet = dictionary["snippet_text"].string
    self.reviewNum = dictionary["review_count"].string
    
    if let imageURLString = dictionary["image_url"].string {
      self.thumbImageURL = URL(string: imageURLString)
    } else {
      self.thumbImageURL = nil
    }
    
    if let categoriesArray = dictionary["categories"].arrayObject as? [[String]] {
      self.categories = categoriesArray.flatMap{$0.first}.joined(separator: ", ")
    } else {
      self.categories = nil
    }
    
    if let distanceMeters = dictionary["distance"].number {
      let milesPerMeter = 0.000621371
      self.distance = String(format: "%.2f mi", milesPerMeter * distanceMeters.doubleValue)
    } else {
      self.distance = nil
    }
  }
  
  class func searchWithTerm(offsetBusinessesResutls: Int?, filters:Filters, completion: @escaping ([Business]?, Error?) -> Void) -> Void {
    _ = YelpClient.sharedInstance.searchWithTerm(offset:offsetBusinessesResutls, filters.searchTerm ?? "", sort: filters.sort, location: filters.location, distance: filters.distance, categories: filters.categories, deals: filters.deals, completion: completion)
  }
  
}
