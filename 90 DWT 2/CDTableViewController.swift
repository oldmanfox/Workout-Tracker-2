////
////  CDTableViewController.swift
////
////  Created by Tim Roadley on 2/10/2015.
////  Copyright © 2015 Tim Roadley. All rights reserved.
////
//
//import UIKit
//import CoreData
//
//class CDTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating {
//    
//    // MARK: - INITIALIZATION
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//    }    
//
//    // MARK: - CELL CONFIGURATION
//    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
//    
//        // Use self.frc.objectAtIndexPath(indexPath) to get an object specific to a cell in the subclasses
//        print("Please override configureCell in \(#function)!")
//    }
//    
//    // Override
////    var entity = "MyEntity"
////    var sort = [NSSortDescriptor(key: "myAttribute", ascending: true)]
//    var entity = "Workout"
//    var sort = [NSSortDescriptor(key: "exercise", ascending: true)]
//    
//    // Optionally Override
//    var context = CDHelper.shared.context
//    var filter:NSPredicate? = nil
//    var cacheName:String? = nil
//    var sectionNameKeyPath:String? = nil
//    var fetchBatchSize = 0 // 0 = No Limit
//    var cellIdentifier = "WorkoutCell"
//    var fetchLimit = 0
//    var fetchOffset = 0
//    var resultType:NSFetchRequestResultType = NSFetchRequestResultType.ManagedObjectResultType
//    var propertiesToGroupBy:[AnyObject]? = nil
//    var havingPredicate:NSPredicate? = nil
//    var includesPropertyValues = true
//    var relationshipKeyPathsForPrefetching:[AnyObject]? = nil
//    
//    // MARK: - FETCHED RESULTS CONTROLLER
//    lazy var frc: NSFetchedResultsController = {
//    
//        let request = NSFetchRequest(entityName:self.entity)
//        request.sortDescriptors = self.sort
//        request.fetchBatchSize  = self.fetchBatchSize
//        if let _filter = self.filter {request.predicate = _filter}
//        
//        request.fetchLimit = self.fetchLimit
//        request.fetchOffset = self.fetchOffset
//        request.resultType = self.resultType
//        request.includesPropertyValues = self.includesPropertyValues
//        if let _propertiesToGroupBy = self.propertiesToGroupBy {request.propertiesToGroupBy = _propertiesToGroupBy}
//        if let _havingPredicate = self.havingPredicate {request.havingPredicate = _havingPredicate}
//        if let _relationshipKeyPathsForPrefetching = self.relationshipKeyPathsForPrefetching as? [String] {
//            request.relationshipKeyPathsForPrefetching = _relationshipKeyPathsForPrefetching}
//        
//        let newFRC = NSFetchedResultsController(
//                            fetchRequest: request,
//                    managedObjectContext: self.context,
//                      sectionNameKeyPath: self.sectionNameKeyPath,
//                               cacheName: self.cacheName)
//        newFRC.delegate = self
//        return newFRC
//    }()
//    
//    // MARK: - FETCHING
//    func performFetch () {
////        self.frc.managedObjectContext.performBlock ({
////
////            do {
////                try self.frc.performFetch()
////                print("Fetching")
////            } catch {
////                print("\(#function) FAILED : \(error)")
////            }
////            self.tableView.reloadData()
////        })
//        
//        do {
//            try self.frc.performFetch()
//            print("Fetching")
//        } catch {
//            print("\(#function) FAILED : \(error)")
//        }
//        self.tableView.reloadData()
//    }
//
//    // MARK: - VIEW
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        // Force fetch when notified of significant data changes
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CDTableViewController.performFetch), name: "SomethingChanged", object: nil)
//    }
//    override func viewDidAppear(animated: Bool) {
//        super.viewDidAppear(animated)
//    }
//        
//    // MARK: - DEALLOCATION
//    deinit {
//        NSNotificationCenter.defaultCenter().removeObserver(self, name: "performFetch", object: nil)
//    }
//    
//    // MARK: - DATA SOURCE: UITableView
//    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        return self.frc.sections?.count ?? 0
//    }
//    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return self.frc.sections![section].numberOfObjects ?? 0
//    }
//    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        
//        var cell:UITableViewCell? = tableView.dequeueReusableCellWithIdentifier(self.cellIdentifier)
//        if cell == nil {
//            cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: self.cellIdentifier)
//        }
//        cell!.selectionStyle = UITableViewCellSelectionStyle.None
//        cell!.accessoryType = UITableViewCellAccessoryType.DetailButton
//        self.configureCell(cell!, atIndexPath: indexPath)
//        return cell!
//    }
//    override func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
//        return self.frc.sectionForSectionIndexTitle(title, atIndex: index)
//    }
//    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return self.frc.sections![section].name ?? ""
//    }
//    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
//        return self.frc.sectionIndexTitles
//    }
//    
//    // MARK: - DELEGATE: NSFetchedResultsController
//    func controllerWillChangeContent(controller: NSFetchedResultsController) {
//        self.tableView.beginUpdates()
//    }
//    func controllerDidChangeContent(controller: NSFetchedResultsController) {
//        self.tableView.endUpdates()
//    }
//    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
//        switch type {
//        case .Insert:
//            print("frc: didChangeSection INSERT")
//            self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
//        case .Delete:
//            print("frc: didChangeSection DELETE")
//            self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
//        default:
//        return
//        }
//    }
//    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
//        
//        switch type {
//        case .Insert:
//            print("frc: didChangeObject INSERT")
//            self.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
//            
//        case .Delete:
//            print("frc: didChangeObject DELETE")
//            self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
//            
//        case .Update:
//            print("frc: didChangeObject UPDATE")
//            /*
//             // Note that for Update, we update the row at __indexPath__
//             let cell = self.tableView.cellForRowAtIndexPath(updateIndexPath)
//             let animal = self.fetchedResultsController.objectAtIndexPath(updateIndexPath) as? Animal
//             
//             cell?.textLabel?.text = animal?.commonName
//             cell?.detailTextLabel?.text = animal?.habitat
//             */
//            
//            self.tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .None)
//        case .Move:
//            print("frc: didChangeObject MOVE")
//            self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
//            self.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
//        }
//    }
//    
//    // MARK: - SEARCH
//    //var searchController:UISearchController? = nil
//    func reloadFRC (predicate:NSPredicate?) {
//            
////        self.filter = predicate
////        self.frc.fetchRequest.predicate = predicate
////        self.performFetch()
//    }
//    func configureSearch () {
//            
////        self.searchController = UISearchController(searchResultsController: nil)
////        if let _searchController = self.searchController {
////
////            _searchController.delegate = self
////            _searchController.searchResultsUpdater = self
////            _searchController.dimsBackgroundDuringPresentation = false
////            _searchController.searchBar.delegate = self
////            _searchController.searchBar.sizeToFit()
////            self.tableView.tableHeaderView = _searchController.searchBar
////                
////        } else {print("ERROR configuring _searchController in %@", #function)}
//    }
//    
//    // MARK: - DELEGATE: UISearchController
//    func updateSearchResultsForSearchController(searchController: UISearchController) {
//        
////        if let searchBarText = searchController.searchBar.text {
////                
////            var predicate:NSPredicate?
////            if searchBarText != "" {
////                predicate = NSPredicate(format: "name contains[cd] %@", searchBarText)
////            }
////            self.reloadFRC(predicate)
////        }
//    }
//    
//    // MARK: - DELEGATE: UISearchBar
//    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
////        self.reloadFRC(nil)
//    }
//}
