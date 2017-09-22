//
//  BusinessVC.swift
//  Lighter Yelp
//
//  Created by user on 9/18/17.
//  Copyright © 2017 YSH. All rights reserved.
//

import UIKit

class BusinessVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var businesses:[Business]!
    var searchFilters:Filters!
    var searchBar: UISearchBar!
    var offsetResults:Int = 20
    var isMoreDataLoading = false
    var loadingMoreView:InfiniteScrollActivityView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
    
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
    
        // Initialize the UISearchBar
        searchBar = UISearchBar()
        searchBar.delegate = self
        
        // Add SearchBar to the NavigationBar
        searchBar.sizeToFit()
        navigationItem.titleView = searchBar
        
        let filterButton = UIBarButtonItem(title: "Filter", style: .plain, target:self, action: #selector(goToFilters))
        navigationItem.leftBarButtonItem = filterButton
        
        searchFilters = Filters()
        
        if let searchTerm = searchBar.text {
            doSearch(term: searchTerm)
        }
        
        // Set up Infinite Scroll loading indicator
        let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.isHidden = true
        tableView.addSubview(loadingMoreView!)
        
        var insets = tableView.contentInset
        insets.bottom += InfiniteScrollActivityView.defaultHeight
        tableView.contentInset = insets
    }

    func goToFilters(){
        performSegue(withIdentifier: "toFilterSettingsVC" , sender: self)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if businesses != nil {
            return businesses.count
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "businessCell", for: indexPath) as! BusinessCell
        
        cell.business = businesses[indexPath.row]
        
        return cell
    }
    
    fileprivate func doSearch(term:String) {
        
        searchFilters.searchTerm = term
        
        Business.searchWithTerm(offsetBusinessesResutls: 0, filters: searchFilters, completion: { (businesses: [Business]?, error: Error?) -> Void in
            
            self.businesses = businesses
            
            if error != nil {
                print (error ?? "an Error in the HTTP Req")
            }
            
            self.tableView.reloadData()
        })
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let filtersVC = segue.destination as? FiltersVC else {return}
        filtersVC.delegate = self
        filtersVC.searchFilters = searchFilters
    }
}

extension BusinessVC: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.isDragging) {
                isMoreDataLoading = true
                
                // Update position of loadingMoreView, and start loading indicator
                let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()
                
                getMoreResults()
            }
        }
    }
    
    fileprivate func getMoreResults() {
        
        Business.searchWithTerm(offsetBusinessesResutls: offsetResults, filters: searchFilters, completion: { (businesses: [Business]?, error: Error?) -> Void in
            
            guard let resultBusinesses = businesses else {return}
            
            for business in resultBusinesses {
                self.businesses.append(business)
            }
            
            self.offsetResults += 20
            
            if error != nil {
                print (error ?? "an Error in the HTTP Req")
            }
            
            self.isMoreDataLoading = false
            self.loadingMoreView!.stopAnimating()
            self.tableView.reloadData()
        })
    }
}

extension BusinessVC: FiltersVCDelegate {
    func dataReceived(filtersVC: FiltersVC, searchFilters: Filters) {
        self.searchFilters = searchFilters
    }
    
    func triggerSearch(filtersVC: FiltersVC) {
        if let searchTerm = searchBar.text {
            doSearch(term: searchTerm)
        }
        
    }
}

extension BusinessVC: UISearchBarDelegate {
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        return true
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(false, animated: true)
        return true
    }

    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchTerm = searchBar.text else {return}
        doSearch(term: searchTerm)
        searchBar.resignFirstResponder()
    }
}

