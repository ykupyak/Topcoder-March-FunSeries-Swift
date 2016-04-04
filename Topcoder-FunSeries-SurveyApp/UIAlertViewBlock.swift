//
//  UIAlertViewBlock.swift
//  Topcoder-FunSeries-SurveyApp
//
//  Created by Yaroslav Kupyak on 4/4/16.
//  Copyright © 2016 topcoder. All rights reserved.
//


import UIKit

class UIAlertViewBlock:NSObject {
    var alertView:UIAlertView?
    var alertViewArray:[[String:Any]] = [[String:Any]]()
    var cancel:[String:Any]?
    var dismissBlock:(()->Void)?
    var title:String?
    var message:String?
    
    func append(item:[String:Any])->Void {
        alertViewArray.append(item)
    }
    
    func appendCancel(item:[String:Any])->Void {
        cancel = item
    }
    
    func onDismiss(block:()->Void) {
        dismissBlock = block
    }
    
    func prepare() {
        
        var cancelTitle = "Cancel"
        
        if cancel != nil {
            cancelTitle = cancel!["title"] as! String
        }
        
        
        alertView = UIAlertView(title: title, message: message, delegate: self, cancelButtonTitle: cancelTitle)
        alertView!.delegate = self
        
        for item in alertViewArray {
            let title = item["title"] as! String
            alertView!.addButtonWithTitle(title)
        }
    }
    
    func show() {
        prepare()
        alertView?.show()
    }
    
}

extension UIAlertViewBlock:UIAlertViewDelegate {
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex > 0 {
            var item = alertViewArray[buttonIndex-1]
            let block = item["block"] as! ()->Void
            block()
        }else {
            if cancel != nil {
                let block = cancel!["block"] as! ()->Void
                block()
            }
        }
        
        if dismissBlock != nil {
            dismissBlock!()
        }
        alertViewArray = [[String:Any]]()
        self.alertView = nil
    }
}