//
//  BusinessVC+Scroll.swift
//  Lighter Yelp
//
//  Created by user on 9/23/17.
//  Copyright © 2017 YSH. All rights reserved.
//

import UIKit

extension BusinessVC: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.isDragging) {
                isMoreDataLoading = true
                
                let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()
                
                getMoreResults()
            }
        }
    }
    
    fileprivate func getMoreResults() {
        
        removAllAnnotations()
        Business.searchWithTerm(offsetBusinessesResutls: offsetResults, filters: searchFilters, completion: { (businesses: [Business]?, error: Error?) -> Void in
            
            guard let resultBusinesses = businesses else {return}
            
            for business in resultBusinesses {
                self.businesses?.append(business)
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