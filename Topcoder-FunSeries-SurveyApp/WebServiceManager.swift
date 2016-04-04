//
//  WebServiceManager.swift
//  Topcoder-FunSeries-SurveyApp
//
//  Created by Anusha Kottiyal on 1/23/16.
//  Copyright © 2016 topcoder. All rights reserved.
//

import UIKit
import CoreData
import Firebase

class WebServiceManager: NSObject {

    // Singleton Instance
    static let sharedManager = WebServiceManager()
    
    func syncSurveyDB() {
        
        let JSONData:NSData = getJSON("http://www.mocky.io/v2/560920cc9665b96e1e69bb46")
        
        
        if let tableData = parseJSON(JSONData) as? [[String: AnyObject]] {
            print(tableData) // show me data
            
            // Updating local store from server
            for item in tableData {
                let req = NSFetchRequest()
                let entity = NSEntityDescription.entityForName("Survey", inManagedObjectContext: CoreDataController.sharedInstance.masterManagedObjectContext)
                let predTemplate = NSPredicate(format: "id = $SURVEY_ID")
                req.entity = entity
                
                if let surveyid = item["id"] as? Int {
                    let predicate = predTemplate.predicateWithSubstitutionVariables(["SURVEY_ID": surveyid])
                    req.predicate = predicate
                    do {
                        if let results = try CoreDataController.sharedInstance.masterManagedObjectContext.executeFetchRequest(req) as? [Survey]{
                            var survey:Survey;
                            
                            //fetching the already filled coredata to check if the isdeleted = set to true
                            if results.count == 0 {
                                survey = NSEntityDescription.insertNewObjectForEntityForName("Survey", inManagedObjectContext: CoreDataController.sharedInstance.masterManagedObjectContext) as! Survey
                                survey.id = item["id"] as? Int
                            } else {
                                survey = results[0]
                                if survey.isdeleted!.boolValue == false {
                                    //
                                    continue
                                }
                            }
                            survey.title = item["title"] as? String
                            survey.desc = item["description"] as? String
                        }
                    }
                    catch let error as NSError {
                        NSLog(" error \(error.localizedDescription), \(error.userInfo)")
                        abort()
                    }
                }
            }
            // save updates from server
            CoreDataController.sharedInstance.saveMasterContext()
    }
    }
    func syncQuestionsDB() {
        
        let JSONData:NSData = getJSON("https://demo2394932.mockable.io/wizard")
        
        if let surveyQuestions = parseJSON(JSONData) as? [[String: AnyObject]] {
            
            // Updating local store from server
            for item in surveyQuestions {
                
                let request = NSFetchRequest()
                let entity = NSEntityDescription.entityForName("SurveyItem", inManagedObjectContext: CoreDataController.sharedInstance.masterManagedObjectContext)
                let predTemplate = NSPredicate(format: "questionId = $QUESTION_ID")
                request.entity = entity
                
                if let questionId = item["id"] as? Int {
                    
                    let predicate = predTemplate.predicateWithSubstitutionVariables(["QUESTION_ID": questionId])
                    request.predicate = predicate
                    
                    do {
                        if let results = try CoreDataController.sharedInstance.masterManagedObjectContext.executeFetchRequest(request) as? [SurveyItem]{
                            var surveyItem:SurveyItem;
                            
                            //fetching the already filled coredata to check if the isdeleted = set to true
                            if results.count == 0 {
                                surveyItem = NSEntityDescription.insertNewObjectForEntityForName("SurveyItem", inManagedObjectContext: CoreDataController.sharedInstance.masterManagedObjectContext) as! SurveyItem
                                surveyItem.questionId = item["id"] as? NSNumber
                            } else {
                                surveyItem = results[0]
                            }
                            surveyItem.question = item["question"] as? String
                            surveyItem.surveyId = item["surveyId"] as? NSNumber
                        }
                    }
                    catch let error as NSError {
                        NSLog(" error \(error.localizedDescription), \(error.userInfo)")
                        abort()
                    }
                }
            }
            
            // save updates from server
            CoreDataController.sharedInstance.saveMasterContext()
        }
    }
    
    func submitSurvey(questionsArray: [SurveyItem], surveyId: NSInteger){
        self.submitSurvey(questionsArray, surveyId: surveyId, image: nil)
    }
    
    func submitSurvey(questionsArray: [SurveyItem], surveyId: NSInteger, image: UIImage?) {
        
        // Create a reference to a Firebase location
        let myRootRef = Firebase(url:"https://popping-fire-3496.firebaseio.com/Survey")
        
        var postingDataArray: [Dictionary<String, NSObject>]? = []
        
        // Create JSON
        for surveyItem in questionsArray {
            
            postingDataArray?.append(surveyItem.getMappingDictionary())
        }
        
        // append image if needs
        if let currentImage = image{            
            // use PNG format for image
            let imageData = UIImagePNGRepresentation(currentImage)
            let base64String = imageData!.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
            postingDataArray?.append([
                "surveyId": surveyId,
                "imageFormat": "png",
                "imageBase64": base64String
                ])
        }
        
        
        var jsonData: NSData?
        do
        {
            jsonData = try  NSJSONSerialization.dataWithJSONObject(postingDataArray!, options: NSJSONWritingOptions.PrettyPrinted)
        } catch
        {
            jsonData = nil
        }
        
        let theJSONText = NSString(data: jsonData!,
            encoding: NSASCIIStringEncoding)
        
        myRootRef.setValue(theJSONText) { (error, firebaseRef) -> Void in
            
            if error == nil {
                
                print("Send data successfully")

            }
        }
    }
    
    //MARK: JSON Handler Methods
    
    func getJSON(urlToRequest: String) -> NSData {
        
        return NSData(contentsOfURL: NSURL(string: urlToRequest)!)!
    }
    
    
    func parseJSON(inputData: NSData) -> NSArray {
        
        let data: NSArray = (try! NSJSONSerialization.JSONObjectWithData(inputData, options: NSJSONReadingOptions.MutableContainers)) as! NSArray
        
        return data
    }
}
