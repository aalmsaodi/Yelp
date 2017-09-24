//
//  BusinessVC.swift
//  Lighter Yelp
//
//  Created by user on 9/18/17.
//  Copyright © 2017 YSH. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class BusinessVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var currentLocationBtn: UIButton!
    @IBOutlet weak var locationBar: UISearchBar!
    @IBOutlet weak var tableViewTopConstrain: NSLayoutConstraint!
    
    var businesses:[Business]?
    var searchFilters:Filters!
    var searchBar: UISearchBar!
    var offsetResults:Int = 20
    var isMoreDataLoading = false
    var loadingMoreView:InfiniteScrollActivityView?
    var locationManager : CLLocationManager!
    var longPressRecognizer:UILongPressGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializingBusinessVC()
    }
    
    func goToFiltersVC() {
        performSegue(withIdentifier: "toFiltersVC" , sender: self)
    }
    
    func viewBusinessesStyle() {
        if navigationItem.rightBarButtonItem?.image == UIImage(named:"map") {
            mapView.isHidden = false
            currentLocationBtn.isHidden = false
            viewBusinessesOnMap()
            navigationItem.rightBarButtonItem?.image = UIImage(named: "list")
        } else {
            mapView.isHidden = true
            currentLocationBtn.isHidden = true
            navigationItem.rightBarButtonItem?.image = UIImage(named: "map")
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toFiltersVC" {
            guard let filtersVC = segue.destination as? FiltersVC else {return}
            filtersVC.delegate = self
            filtersVC.searchFilters = searchFilters
        
        } else if segue.identifier == "fromMapToDetailsVC" {
            guard let detailsVC = segue.destination as? DetailsVC else {return}
            if let mapAnnotation = sender as? MKAnnotation {
                let index = Int(mapAnnotation.title!!)
                detailsVC.business = businesses?[index!]
            }
            
        } else if segue.identifier == "fromCellToDetailsVC" {
            guard let detailsVC = segue.destination as? DetailsVC else {return}
            if let cell = sender as? BusinessCell {
                let index = tableView.indexPath(for: cell)?.row
                detailsVC.business = businesses?[index!]
            }
        }
    }
}


extension BusinessVC: FiltersVCDelegate {
    func dataReceived(filtersVC: FiltersVC, searchFilters: Filters) {
        self.searchFilters = searchFilters
    }
    
    func triggerSearch(filtersVC: FiltersVC) {
            doSearch()
    }
}






