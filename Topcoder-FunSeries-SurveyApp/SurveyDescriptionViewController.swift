//
//  SurveyDescriptionViewController.swift
//  Topcoder-FunSeries-SurveyApp
//
//  Created by Anusha Kottiyal on 1/21/16.
//  Copyright © 2016 topcoder. All rights reserved.
//

import UIKit
import CoreData

class SurveyDescriptionViewController: UIViewController {
    
    var surveyWizardDelegate: SurveyWizardScreenDelegate?
    
    @IBOutlet weak var textView: UITextView!
    var survey: Survey?
    
    var descriptionString: String?
    var surveyTitle: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = self.survey?.title?.capitalizedString
        self.textView.text = self.survey?.desc
    }
    
    //MARK: Segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "LaunchServeySegueIdentifier" {
            
            let destinationVC = segue.destinationViewController as! SurveyWizardViewController
            destinationVC.selectedSurvey = self.survey
            destinationVC.surveyId = (self.survey?.id?.integerValue)!
            destinationVC.delegate = surveyWizardDelegate
            
            // Set back button title
            let backButtonItem = UIBarButtonItem()
            backButtonItem.title = "Back"
            navigationItem.backBarButtonItem = backButtonItem
        }
    }
}
