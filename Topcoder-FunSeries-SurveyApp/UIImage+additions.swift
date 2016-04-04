//
//  UIImage+additions.swift
//  Topcoder-FunSeries-SurveyApp
//
//  Created by Yaroslav Kupyak on 4/4/16.
//  Copyright © 2016 topcoder. All rights reserved.
//

import UIKit

public extension UIImage {
    
    func scaledImage(toSize newSize: CGSize) -> (UIImage) {
        let hasAlpha = false
        let scale: CGFloat = 1.0

        UIGraphicsBeginImageContextWithOptions(newSize, !hasAlpha, scale)
        self.drawInRect(CGRect(origin: CGPointZero, size: newSize))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
}