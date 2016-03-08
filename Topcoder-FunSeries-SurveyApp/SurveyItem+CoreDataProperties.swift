//
//  SurveyItem+CoreDataProperties.swift
//  Topcoder-FunSeries-SurveyApp
//
//  Created by Anusha Kottiyal on 1/21/16.
//  Copyright © 2016 topcoder. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension SurveyItem {

    @NSManaged var answer: String?
    @NSManaged var question: String?
    @NSManaged var questionId: NSNumber?
    @NSManaged var surveyId: NSNumber?

}
