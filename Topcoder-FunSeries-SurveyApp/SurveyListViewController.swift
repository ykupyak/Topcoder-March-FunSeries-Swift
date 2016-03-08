//
//  SurveyListViewController.swift
//  Topcoder-FunSeries-SurveyApp
//
//  Created by Anusha Kottiyal on 1/23/16.
//  Copyright © 2016 topcoder. All rights reserved.
//

import UIKit
import CoreData

class SurveyListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate, NSFetchedResultsControllerDelegate, SurveyWizardScreenDelegate {
    
    var fetchController:NSFetchedResultsController = NSFetchedResultsController()
    
    var dataArray:NSMutableArray!
    var plistPath:String!
    var filteredData: [String] = []
    var titleData :[String] = []
    var i: Int = 0
    var flag: Bool = false;
    var selectedSurvey: Survey?
    
    @IBOutlet var surveyTableSearchBar: UISearchBar!
    
    @IBOutlet var surveyTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        surveyTable.delegate=self;
        surveyTable.dataSource=self;
        
        // Sync Survey DB
        WebServiceManager.sharedManager.syncSurveyDB()
        
        // Fetching data from local store
        self.fetchSurveyList()
        
        // Add done button in search bar keyboard
        let doneToolbar: UIToolbar = UIToolbar()
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let doneButton: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: Selector("hideKeyboard"))
        
        doneToolbar.items = [flexibleSpace, doneButton]
        doneToolbar.sizeToFit()
        
        self.surveyTableSearchBar.inputAccessoryView = doneToolbar
    }
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        
        // Clear selection
        let indexPath: NSIndexPath? = self.surveyTable.indexPathForSelectedRow
        if (indexPath != nil) {
            
            self.surveyTable.deselectRowAtIndexPath(indexPath!, animated: true)
        }
    }
    
    func hideKeyboard() {
        
        self.surveyTableSearchBar.resignFirstResponder()
    }
    
    //Search Bar functions
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        flag = true;
        var predicate:NSPredicate?
        
        if searchText != "" {
            
            predicate = NSPredicate(format: "title contains[cd] %@ AND isdeleted = 0", searchText)
        }
        
        self.fetchController.fetchRequest.predicate = predicate
        
        do {
            try self.fetchController.performFetch()
        } catch let error as NSError {
            print("fetch error: %@", error.localizedDescription)
        }
        
        surveyTable.reloadData()
    }
    
    //MARK: Prepare For Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            let destinationVC = segue.destinationViewController as! SurveyDescriptionViewController
            destinationVC.survey = self.selectedSurvey
            destinationVC.surveyWizardDelegate = self
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchSurveyList() {
        
        let request = NSFetchRequest()
        let entity = NSEntityDescription.entityForName("Survey", inManagedObjectContext:CoreDataController.sharedInstance.masterManagedObjectContext)
        
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        let predicate = NSPredicate(format:"isdeleted = 0")
        request.predicate = predicate
        request.entity = entity
        request.sortDescriptors = [sortDescriptor]
        
        self.fetchController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: CoreDataController.sharedInstance.masterManagedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        self.fetchController.delegate = self
        do {
            try self.fetchController.performFetch()
        }catch let error as NSError {
            print("fetch error: %@", error.localizedDescription)
        }
    }
    
    //MARK: TableView DataSource and Delegate Methods
    
    func numberOfSectionsInTableView(SurveyTable: UITableView) -> Int {
        if let sections =  self.fetchController.sections {
            return sections.count
        }
        return 0
    }
    
    
    func tableView(SurveyTable: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let fetchedObjects =  self.fetchController.fetchedObjects {
            return fetchedObjects.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let surveys = self.fetchController.fetchedObjects as? [Survey] {
            self.selectedSurvey = surveys[indexPath.row]
            self.performSegueWithIdentifier("showDetail", sender: nil)
        }
    }
    
    func tableView(SurveyTable: UITableView,
        cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
            let cell1 = SurveyTable.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
            
            if let surveys = self.fetchController.fetchedObjects as? [Survey] {
                cell1.textLabel?.text = surveys[indexPath.row].title?.capitalizedString
            }
            
            return cell1
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            if let survey = self.fetchController.objectAtIndexPath(indexPath) as? Survey {
                survey.isdeleted = NSNumber(bool: true)
                
                // Save
                CoreDataController.sharedInstance.saveMasterContext()
            }
        }
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        surveyTable.beginUpdates()
    }
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        surveyTable.endUpdates()
    }
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        print("row \(indexPath!.row)")
        
        switch(type) {
        case .Update: fallthrough
        case .Delete:
            surveyTable.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
            surveyTable.reloadData();
            break
        default:
            break
            
        }
    }
    
    func surveyWizardScreen(controller: SurveyWizardViewController, didcompleteSurvey survey:Survey?) {
        
        self.navigationController?.popToRootViewControllerAnimated(true)
        
        // Show Alert
        let alertController = UIAlertController(title: "Survey Completed", message:
            "Thank you for completing our survey '\(survey!.title! as String)'", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))

        self.presentViewController(alertController, animated: true, completion: nil)
    }
}
