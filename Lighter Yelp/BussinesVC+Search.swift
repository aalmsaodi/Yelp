//
//  BussinesVC+Search.swift
//  Lighter Yelp
//
//  Created by user on 9/23/17.
//  Copyright © 2017 YSH. All rights reserved.
//

import UIKit
import SVProgressHUD

extension BusinessVC: UISearchBarDelegate {
    
    func doSearch() {
        
        SVProgressHUD.show()
        removAllAnnotations()
        
        Business.searchWithTerm(offsetBusinessesResutls: 0, filters: searchFilters, completion: { (businesses: [Business]?, error: Error?) -> Void in
            guard let businessesResponse = businesses else {return}
            self.businesses = businessesResponse
            
            if error != nil {
                print (error ?? "an Error in the HTTP Req")
            }
            
            SVProgressHUD.dismiss()
            self.setupMapRegionAndSpan()
            self.viewBusinessesOnMap()
            self.tableView.reloadData()
        })
    }
    
    
    func searchBarShouldBeginEditing(_ sBar: UISearchBar) -> Bool {
        showLocationBar()
        locationBar.setShowsCancelButton(true, animated: true)
        return true
    }
    
    
    func searchBarSearchButtonClicked(_ sBar: UISearchBar) {
        guard let inputText = sBar.text else {return}
        
        if let term = searchBar.text {
            searchFilters.searchTerm = term
        }
        
        //setting location and searching if event come from location bar
        if sBar == locationBar {
            if inputText.lowercased() == "current location" {
                locationManager.startUpdatingLocation()
            } else {
                setSearchLocationCoordinates()
            }
        }
        
        //searching only if event comes from search bar
        if sBar == searchBar {
            doSearch()
        }
        
        sBar.resignFirstResponder()
        hideLocationBar()
    }
    
    func searchBarCancelButtonClicked(_ sBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        locationBar.resignFirstResponder()
        hideLocationBar()
    }
    
    
// MARK: - Search helping functions *******************************************************************
    func hideLocationBar() {
        locationBar.isHidden = true
        tableViewTopConstrain.constant = 0
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    func showLocationBar() {
        locationBar.isHidden = false
        tableViewTopConstrain.constant = locationBar.bounds.size.height
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    func activateLocationBarCancelButton() {
        for view in locationBar.subviews {
            for subview in view.subviews {
                if let button = subview as? UIButton {
                    button.isEnabled = true
                }
            }
        }
    }
    
}
