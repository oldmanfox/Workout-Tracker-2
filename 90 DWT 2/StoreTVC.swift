//
//  StoreTVC.swift
//  90 DWT 2
//
//  Created by Grant, Jared on 6/23/16.
//  Copyright © 2016 Grant, Jared. All rights reserved.
//

import UIKit

class StoreTVC: UITableViewController {
    
    var products = [SKProduct]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Store"
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(StoreTVC.reload), for: .valueChanged)
        
        let restoreButton = UIBarButtonItem(title: "Restore", style: .plain, target: self, action: #selector(StoreTVC.restoreTapped(_:)))
        navigationItem.rightBarButtonItem = restoreButton
        
        NotificationCenter.default.addObserver(self, selector: #selector(StoreTVC.handlePurchaseNotification(_:)),
                                                         name: NSNotification.Name(rawValue: IAPHelper.IAPHelperPurchaseNotification),
                                                         object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        reload()
    }
    
    @objc func reload() {
        
        products = []
        
        //tableView.reloadData()
        
        Products.store.requestProducts{success, products in
            if success {
                self.products = products!
                
                self.tableView.reloadData()
            }
            
            self.refreshControl?.endRefreshing()
        }
    }
    
    @objc func restoreTapped(_ sender: AnyObject) {
        Products.store.restorePurchases()
    }
    
    @objc func handlePurchaseNotification(_ notification: Notification) {
        guard let productID = notification.object as? String else { return }
        
        for (index, product) in products.enumerated() {
            guard product.productIdentifier == productID else { continue }
            
            tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .fade)
        }
    }
}

// MARK: - UITableViewDataSource

extension StoreTVC {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            
            return products.count
        } else {
            
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "PaidCell", for: indexPath) as! ProductCell
            
            let product = products[indexPath.row]
            
            cell.product = product
            cell.buyButtonHandler = { product in
                Products.store.buyProduct(product)
            }

            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "AdCell", for: indexPath) as! StoreRewardVideoTableViewCell
            
            cell.titleLabel.text = "1-HR Graph View"
            cell.priceLabel.text = ""
            cell.descriptionLabel.text = "View a reward video to gain access to the Graph View for 1-hour."
            cell.viewButton.titleLabel?.text = "VIEW"
            
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if section == 0 {
            
            return "PAID"
        }
        else {
            
            return "AD SUPPORTED"
        }
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        // Set the color of the header/footer text
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.white
        
        // Set the background color of the header/footer
        header.contentView.backgroundColor = UIColor.lightGray
    }
    
    // MARK: - Navigation
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
        // Rewarded Ad Unit
        if identifier == "RewardVideo" && MPRewardedVideo.hasAdAvailable(forAdUnitID: "c9130834e2324aa281a4b59dbcc41301"){
            
            return true
        }
        else {
            
            return false
        }
    }
}

