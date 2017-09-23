//
//  FiltersCell.swift
//  Lighter Yelp
//
//  Created by user on 9/21/17.
//  Copyright © 2017 YSH. All rights reserved.
//

import UIKit

class SwitchCell: UITableViewCell {

    @IBOutlet weak var parameterLabel: UILabel!
    @IBOutlet weak var onOffSwitch: UISwitch!
    
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
            case filterParameters.deals.rawValue:
                parameterLabel.text = "Offering a Deal"
                if let switchState = filters.deals {
                    onOffSwitch.isOn = switchState
                }
                onOffSwitch.tag = -1
                onOffSwitch.addTarget(self, action: #selector(dealAdded), for: .valueChanged)
                
            case filterParameters.category.rawValue:
                parameterLabel.text = Constants.CATEGORIES[elementIndex]["name"]
                
                if filters.categories.contains(Constants.CATEGORIES[elementIndex]["code"]!) {
                    onOffSwitch.isOn = true
                } else {
                    onOffSwitch.isOn = false
                }
                onOffSwitch.tag = elementIndex
                onOffSwitch.addTarget(self, action: #selector(categoryChosen), for: .valueChanged)
                
            default:
                parameterLabel.text = "N/A"
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func dealAdded(sender: UISwitch) {
        if sender.isOn {
            filters.deals = true
        } else {
            filters.deals = false
        }
    }
    
    func categoryChosen(sender: UISwitch) {
        if sender.tag > -1 {
            
            if sender.isOn {
                filters.categories.append(Constants.CATEGORIES[sender.tag]["code"]!)
            } else {
                filters.categories.remove(at: filters.categories.index(of: Constants.CATEGORIES[sender.tag]["code"]!)!)
            }
        }
    }

}

