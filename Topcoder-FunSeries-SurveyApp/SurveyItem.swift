//
//  SurveyItem.swift
//  Topcoder-FunSeries-SurveyApp
//
//  Created by Anusha Kottiyal on 1/21/16.
//  Copyright © 2016 topcoder. All rights reserved.
//

import Foundation
import CoreData

@objc(SurveyItem)
class SurveyItem: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    
    func getMappingDictionary() -> Dictionary<String, String> {
    
        
        
        let ansString = (self.answer != nil) ? self.answer : ""
        
        if let surveyId = self.surveyId{
            if let questionId = self.questionId{
                return ["surveyId": "\(surveyId)", "questionId": "\(questionId)", "answer": ansString!]
            }
        }
        return  [:]
    }

}
