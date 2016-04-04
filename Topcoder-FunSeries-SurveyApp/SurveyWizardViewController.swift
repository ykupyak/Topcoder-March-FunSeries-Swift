//
//  SurveyWizardViewController.swift
//  Topcoder-FunSeries-SurveyApp
//
//  Created by Anusha Kottiyal on 1/20/16.
//  Copyright © 2016 topcoder. All rights reserved.
//

import UIKit
import CoreData

protocol SurveyWizardScreenDelegate {
    
    func surveyWizardScreen(controller: SurveyWizardViewController, didcompleteSurvey survey:Survey?)
}

class SurveyWizardViewController: UIViewController, UITextViewDelegate {
    
    var delegate: SurveyWizardScreenDelegate?
    
    var surveyId: NSInteger = -1
    var questionIndex: NSInteger = -1
    var selectedSurvey: Survey?
    
    var questionsArray: [SurveyItem]?
    
    @IBOutlet weak var holderView: UIView!
    
    @IBOutlet weak var questionView: UITextView!
    @IBOutlet weak var answerView: UITextView!
    
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var lastButton: UIButton!
    
    @IBOutlet weak var exceptionView: UIView!
    @IBOutlet weak var exceptionLabel: UILabel!
    
    //MARK - Life cycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure UI
        self.configureUI()
        
        // Set title
        self.title = "Survey"
        
        if (self.surveyId >= 0) {
            
            // Sync questions db
            WebServiceManager.sharedManager.syncQuestionsDB()
            
            // Fetch questions in selected survey
            self.fetchQuestions(self.surveyId)
            
            if (questionsArray?.count > 0) {
                
                questionIndex = 0
                self.updateUI()
                
            } else {
                
                // No questions available
                self.showExceptionMessage("Questions not available for the selected survey")
            }
        } else {
            
            // Invalid Survey
            self.showExceptionMessage("Selected survey is not valid any more.")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - UI Methods
    
    func configureUI() {
        
        // Add effects to views
        
        // Question View
        self.questionView!.layer.masksToBounds = false
        self.questionView!.layer.shadowOffset = CGSizeMake(7, 7)
        self.questionView!.layer.shadowColor = UIColor.blackColor().CGColor
        self.questionView!.layer.shadowRadius = 38;
        self.questionView!.layer.shadowOpacity = 0.8;
        self.questionView!.layer.cornerRadius = 0.7

        
        // Answer View
        self.answerView!.layer.masksToBounds = false
        self.answerView!.layer.shadowOffset = CGSizeMake(7, 7)
        self.answerView!.layer.shadowColor = UIColor.blackColor().CGColor
        self.answerView!.layer.shadowRadius = 38;
        self.answerView!.layer.shadowOpacity = 0.8;
        self.answerView!.layer.borderWidth = 1
        self.answerView!.layer.borderColor = UIColor(red: 72/255, green: 128/255, blue: 30/255, alpha: 1.0).CGColor
    }
    
    func updateUI() {
        
        // Update UI based on question index
        switch(questionIndex) {
        case 0:
            self.previousButton.hidden = true
        case 1:
            self.previousButton.hidden = false
        case (questionsArray?.count)! - 2:
            self.nextButton.setTitle("Next", forState:.Normal)
            self.lastButton.hidden = false
        case (questionsArray?.count)! - 1:
            self.nextButton.setTitle("Finish", forState:.Normal)
            self.lastButton.hidden = true
        default:
            break
        }
        
        // Update question and answer
        self.updateQuestion()
    }
    
    func updateQuestion() {
        
        let surveyItem = questionsArray![questionIndex] as SurveyItem
        
        self.questionView.text = surveyItem.question
        self.answerView.text = surveyItem.answer
    }
    
    //MARK: - Fetch Questions
    func fetchQuestions(surveyId: NSInteger) {
        
        // Fetching data from local store
        let request = NSFetchRequest()
        let entity = NSEntityDescription.entityForName("SurveyItem", inManagedObjectContext: CoreDataController.sharedInstance.masterManagedObjectContext)
        
        let sortDescriptor = NSSortDescriptor(key: "questionId", ascending: true)
        let predicate = NSPredicate(format:"surveyId = %d", self.surveyId)
        request.predicate = predicate
        request.entity = entity
        request.sortDescriptors = [sortDescriptor]
        
        do {
            if let results = try CoreDataController.sharedInstance.masterManagedObjectContext.executeFetchRequest(request) as? [SurveyItem] {
                
                // Assign questions array
                self.questionsArray = results
            }
        }
        catch let error as NSError {
            NSLog(" error \(error.localizedDescription), \(error.userInfo)")
            abort()
        }
    }
    
    //MARK: - Exception Handler
    
    func showExceptionMessage(message: String) {
        
        self.holderView.hidden = true
        self.exceptionView.hidden = false
        
        self.exceptionLabel.text = message
    }
    
    //MARK: - Interface Builder Methods
    
    @IBAction func showPreviousQuestion(sender: AnyObject) {
        
        questionIndex -= 1
        self.updateUI()
    }
    
    @IBAction func showNextQuestion(sender: AnyObject) {
        
        if (questionIndex < (questionsArray?.count)! - 1) {
            
            // Show Next Question
            questionIndex += 1
            self.updateUI()
        } else {
            
            // Finish Survey
            WebServiceManager.sharedManager.submitSurvey(questionsArray!)
            
            // Inform Delegates
            self.delegate?.surveyWizardScreen(self, didcompleteSurvey: self.selectedSurvey)
        }
    }
    
    @IBAction func showLastQuestion(sender: AnyObject) {
        if (questionIndex < (questionsArray?.count)! - 1) {
            
            // Show Last Question
            questionIndex = (questionsArray?.count)! - 1
            self.updateUI()
        }
    }
    
    
    //MARK: - TextView Delegate Methods
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        if (text == "\n") {
            
            textView.resignFirstResponder()
            return false
        }
        
        return true
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        
        let surveyItem = questionsArray![questionIndex]
        surveyItem.answer = self.answerView.text
        
        // Save answer in core data
        CoreDataController.sharedInstance.saveMasterContext()
    }
}
