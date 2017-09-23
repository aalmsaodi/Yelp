//
//  FiltersSelectCells.swift
//  Lighter Yelp
//
//  Created by user on 9/22/17.
//  Copyright © 2017 YSH. All rights reserved.
//

import UIKit

class SelectCell: UITableViewCell {
    
    @IBOutlet weak var parameterLabel: UILabel!
    
    var parameterType:Int!
    var elementIndex:Int!
    var indexPath:IndexPath! {
        didSet {
            parameterType = indexPath.section
            elementIndex = indexPath.row
        }
    }
    
    var filters:Filters! {
        didSet {
            
            switch parameterType {
            case filterParameters.distance.rawValue:
                parameterLabel.text = (Constants.DISTANCE[elementIndex]["name"] as! String)
                if filters.distance == (Constants.DISTANCE[elementIndex]["code"] as! Int) {
                    accessoryType = .checkmark
                } else {
                    accessoryType = .none
                }
                
            case filterParameters.sort.rawValue:
                parameterLabel.text = (Constants.SORT[elementIndex]["name"] as! String)
                if filters.sort.rawValue == Constants.SORT[elementIndex]["code"] as! Int {
                    accessoryType = .checkmark
                } else {
                    accessoryType = .none
                }
                
            default:
                parameterLabel.text = "N/A"
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }
    
}
