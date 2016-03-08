//
//  CoreDataController.swift
//  Topcoder-FunSeries-SurveyApp
//
//  Created by Anusha Kottiyal on 1/23/16.
//  Copyright © 2016 topcoder. All rights reserved.
//

import UIKit
import CoreData

class CoreDataController: NSObject {

    // Singleton Instance
    static let sharedInstance = CoreDataController()
    
    //MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.hywong.sample.RunKeper" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        print (urls[urls.count-1])
        return urls[urls.count-1]
    }()
    
    // Used to propegate saves to the persistent store (disk) without blocking the UI
    lazy var masterManagedObjectContext: NSManagedObjectContext = {
        
        
        let coordinator = self.persistentStoreCoordinator
        var masterManagedObjectContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        masterManagedObjectContext.performBlockAndWait({ () -> Void in
            
            masterManagedObjectContext.persistentStoreCoordinator = coordinator
        })
        
        return masterManagedObjectContext
        
    }()

    
    // Return the NSManagedObjectContext to be used in the background during sync
    lazy var backgroundManagedObjectContext: NSManagedObjectContext = {
        
        var backgroundManagedObjectContext: NSManagedObjectContext?
        var masterContext: NSManagedObjectContext? = self.masterManagedObjectContext
        
        if (masterContext != nil) {
            
            backgroundManagedObjectContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
            backgroundManagedObjectContext!.performBlockAndWait({ () -> Void in
                
                backgroundManagedObjectContext!.parentContext = masterContext
            })
        }
        
        return backgroundManagedObjectContext!
        }()
        
    // Return the NSManagedObjectContext to be used in the background during sync
    lazy var newManagedObjectContext: NSManagedObjectContext = {
        
        var newContext: NSManagedObjectContext?
        var masterContext: NSManagedObjectContext? = self.masterManagedObjectContext
        
        if (masterContext != nil) {
            
            newContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
            newContext!.performBlockAndWait({ () -> Void in
                
                newContext!.parentContext = masterContext
            })
        }
        
        return newContext!
        }()
    
    func saveMasterContext() {
        
        if masterManagedObjectContext.hasChanges {
            do {
                try masterManagedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Could not save master context due to unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
    func saveBackgroundContext() {
        
        if backgroundManagedObjectContext.hasChanges {
            do {
                try backgroundManagedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Could not save background context due to unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }

    // Returns the managed object model for the application.
    // If the model doesn't already exist, it is created from the application's model.
    lazy var managedObjectModel: NSManagedObjectModel = {
    
        let bundle = NSBundle(forClass: self.dynamicType)
        let modelURL = bundle.URLForResource("SurveyModel", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    // Returns the persistent store coordinator for the application.
    // If the coordinator doesn't already exist, it is created and the application's store added to it.
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
}
