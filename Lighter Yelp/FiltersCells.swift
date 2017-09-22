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
    
    var filters:Filters! {
        didSet {
//            parameterLabel.text = 
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

}


class SelectCell: UITableViewCell {
    
    @IBOutlet weak var parameterLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
