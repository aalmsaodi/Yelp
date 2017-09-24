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
        
        let searchButton = UIBarButtonItem(image: UIImage(named: "search"), style: .plain, target:self, action: #selector(searchBtnTapped))
        let cancelButton = UIBarButtonItem(image: UIImage(named: "cancel"), style: .plain, target:self, action: #selector(cancelBtnTapped))
        
        navigationItem.rightBarButtonItem = cancelButton
        navigationItem.leftBarButtonItem = searchButton
    }
    
    func cancelBtnTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    func searchBtnTapped() {
        delegate?.dataReceived(filtersVC: self, searchFilters: searchFilters)
        delegate?.triggerSearch(filtersVC: self)
        navigationController?.popViewController(animated: true)
    }
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == filterParameters.distance.rawValue || indexPath.section == filterParameters.sort.rawValue {
            guard  let cell = tableView.dequeueReusableCell(withIdentifier: "selectCell") as? SelectCell else {return UITableViewCell()}
            
            cell.indexPath = indexPath
            cell.filters = searchFilters
            return cell
            
        } else {
            guard  let cell = tableView.dequeueReusableCell(withIdentifier: "switchCell") as? SwitchCell else {return UITableViewCell()}
            
            cell.indexPath = indexPath
            cell.filters = searchFilters
            return cell
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
        
        let headerView = UITableViewHeaderFooterView(frame: CGRect(x: 0, y: 0, width: 320, height: 20))
        headerView.contentView.backgroundColor = UIColor(colorLiteralRed: 0xd3/0xFF, green: 0x23/0xFF, blue: 0x23/0xFF, alpha: 0.5)
        
        let headerImageView = UIImageView(frame: CGRect(x: headerView.bounds.width-35, y: 5, width: headerView.bounds.height, height: headerView.bounds.height))
        if sectionBooleans[section] {
            let headerImage = UIImage(named: "arrowUp")
            headerImageView.image = headerImage
        } else {
            let headerImage = UIImage(named: "arrowDown")
            headerImageView.image = headerImage

        }
        headerView.addSubview(headerImageView)
        
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
            if !sectionBooleans[section] {
                return Constants.DISTANCE.count
            } else {
                return 0
            }
        case filterParameters.sort.rawValue:
            if !sectionBooleans[section] {
                return Constants.SORT.count
            } else {
                return 0
            }
        case filterParameters.category.rawValue:
            if sectionBooleans[section] {
                return Constants.CATEGORIES.count
            } else {
                return 3
            }
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case filterParameters.deals.rawValue:
            return nil//"Deal"
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
