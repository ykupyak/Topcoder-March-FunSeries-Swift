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
    
    func getMappingDictionary() -> Dictionary<String, NSObject> {
        if let surveyId = self.surveyId{
            if let questionId = self.questionId{
                if let answer = self.answer{
                    return  ["surveyId": surveyId, "questionId": questionId, "answer": answer]
                }
                else{
                    return  ["surveyId": surveyId, "questionId": questionId, "answer": ""]
                }
            }
        }
        return  [:]
    }

}
