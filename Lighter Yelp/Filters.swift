//
//  Filters.swift
//  Lighter Yelp
//
//  Created by user on 9/21/17.
//  Copyright © 2017 YSH. All rights reserved.
//

import Foundation

class Filters {
    
    let MAX_RADIUS = 40000 //in meters
    
    var searchTerm:String?
    var categories:[String]!
    var sort:YelpSortMode!
    var distance:Int? {
        didSet{
            if distance! > MAX_RADIUS {
                distance = MAX_RADIUS
            }
        }
    }
    var deals:Bool!
    var location:String!
    
    init() {
        self.categories = [String]()
        self.deals = false
        self.sort = YelpSortMode.bestMatched
        self.distance = (Constants.DISTANCE[0]["code"] as! Int)
        self.location = "San Jose"
    }
}
    
