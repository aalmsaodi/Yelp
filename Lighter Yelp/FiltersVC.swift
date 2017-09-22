//
//  FiltersVC.swift
//  Lighter Yelp
//
//  Created by user on 9/21/17.
//  Copyright © 2017 YSH. All rights reserved.
//

import UIKit

enum filterParameters: Int {
    case deals = 0, distance, sort, category
    static var count: Int { return filterParameters.category.hashValue + 1}
}


protocol FiltersVCDelegate: class {
    func dataReceived(filtersVC:FiltersVC, searchFilters:Filters)
    func triggerSearch(filtersVC:FiltersVC)
}

class FiltersVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var searchFilters:Filters!
    weak var delegate:FiltersVCDelegate?
    var sectionBooleans = [Bool](repeating: false, count: filterParameters.count)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.estimatedRowHeight = 40
        tableView.rowHeight = UITableViewAutomaticDimension
        
        let searchButton = UIBarButtonItem(title: "Search", style: .plain, target:self, action: #selector(searchBtnTapped))
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target:self, action: #selector(cancelBtnTapped))
        
        navigationItem.rightBarButtonItem = cancelButton
        navigationItem.leftBarButtonItem = searchButton
        
    }
    
    func cancelBtnTapped() {
        
    }
    
    func searchBtnTapped() {
        delegate?.dataReceived(filtersVC: self, searchFilters: searchFilters)
        delegate?.triggerSearch(filtersVC: self)
        navigationController?.popViewController(animated: true)
    }
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == filterParameters.distance.rawValue || indexPath.section == filterParameters.sort.rawValue {
            guard  let cell = tableView.dequeueReusableCell(withIdentifier: "selectCell") as? SelectCell else {return UITableViewCell()}
            
            switch indexPath.section {
            case filterParameters.distance.rawValue:
                cell.parameterLabel.text = (Constants.DISTANCE[indexPath.row]["name"] as! String)
                if searchFilters.distance == (Constants.DISTANCE[indexPath.row]["code"] as! Int) {
                    cell.accessoryType = .checkmark
                } else {
                    cell.accessoryType = .none
                }
                
            case filterParameters.sort.rawValue:
                cell.parameterLabel.text = (Constants.SORT[indexPath.row]["name"] as! String)
                if searchFilters.sort.rawValue == Constants.SORT[indexPath.row]["code"] as! Int {
                    cell.accessoryType = .checkmark
                } else {
                    cell.accessoryType = .none
                }
                
            default:
                cell.parameterLabel.text = "N/A"
            }
            
            return cell
            
        } else {
            guard  let cell = tableView.dequeueReusableCell(withIdentifier: "switchCell") as? SwitchCell else {return UITableViewCell()}
            
            switch indexPath.section {
            case filterParameters.deals.rawValue:
                cell.parameterLabel.text = "Offering a Deal"
                if let switchState = searchFilters.deals {
                    cell.onOffSwitch.isOn = switchState
                }
                cell.onOffSwitch.tag = -1
                cell.onOffSwitch.addTarget(self, action: #selector(dealAdded), for: .valueChanged)
            
            case filterParameters.category.rawValue:
                cell.parameterLabel.text = Constants.CATEGORIES[indexPath.row]["name"]
                
                if searchFilters.categories.contains(Constants.CATEGORIES[indexPath.row]["code"]!) {
                    cell.onOffSwitch.isOn = true
                } else {
                    cell.onOffSwitch.isOn = false
                }
                cell.onOffSwitch.tag = indexPath.row
                cell.onOffSwitch.addTarget(self, action: #selector(categoryChosen), for: .valueChanged)
            
            default:
                cell.parameterLabel.text = "N/A"
            }
            return cell
        }
    }
    
    func dealAdded(sender: UISwitch) {
        if sender.isOn {
            searchFilters.deals = true
        } else {
            searchFilters.deals = false
        }
    }
    
    func categoryChosen(sender: UISwitch) {
        if sender.tag > -1 {
            
            if sender.isOn {
                searchFilters.categories.append(Constants.CATEGORIES[sender.tag]["code"]!)
            } else {
                searchFilters.categories.remove(at: searchFilters.categories.index(of: Constants.CATEGORIES[sender.tag]["code"]!)!)
            }
        }
    }
   
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == filterParameters.distance.rawValue {
            searchFilters.distance = (Constants.DISTANCE[indexPath.row]["code"] as! Int)
        } else if indexPath.section == filterParameters.sort.rawValue {
            searchFilters.sort = YelpSortMode(rawValue: Constants.SORT[indexPath.row]["code"] as! YelpSortMode.RawValue)
        }
        

        tableView.reloadData()
    }
    
    
    func tableViewHeaderTapped(gestureRecognizer: UIGestureRecognizer) {
        let headerView = gestureRecognizer.view;
        sectionBooleans[(headerView?.tag)!] = !sectionBooleans[(headerView?.tag)!]
        tableView.reloadSections(NSIndexSet(index: (headerView?.tag)!) as IndexSet, with: UITableViewRowAnimation.automatic)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UITableViewHeaderFooterView(frame: CGRect(x: 0, y: 0, width: 320, height: 45))
        headerView.contentView.backgroundColor = UIColor(colorLiteralRed: 0x95/0xFF, green: 0xA3/0xFF, blue: 0xA4/0xFF, alpha: 0.9)
        headerView.tag = section
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tableViewHeaderTapped))
        tapRecognizer.delegate = self as? UIGestureRecognizerDelegate
        headerView.addGestureRecognizer(tapRecognizer)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case filterParameters.deals.rawValue:
            return 1
        case filterParameters.distance.rawValue:
            if sectionBooleans[section] {
                return Constants.DISTANCE.count
            } else {
                return 1
            }
        case filterParameters.sort.rawValue:
            return Constants.SORT.count
        case filterParameters.category.rawValue:
            if sectionBooleans[section] {
                return Constants.CATEGORIES.count
            } else {
                return 1
            }
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case filterParameters.deals.rawValue:
            return "Deal"
        case filterParameters.distance.rawValue:
            return "Distance"
        case filterParameters.sort.rawValue:
            return "Sort by"
        case filterParameters.category.rawValue:
            return "Category"
        default:
            return ""
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return filterParameters.count
    }
    
}
