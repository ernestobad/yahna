//
//  StringExtensions.swift
//  yahna
//
//  Created by Ernesto Badillo on 10/7/19.
//  Copyright © 2019 Ernesto Badillo. All rights reserved.
//

import Foundation
import UIKit

extension String {
    
    func attributedStringFromHtmlEncodedString() -> NSAttributedString? {
        
        let str = self
        
        guard let data = str.data(using: .utf8) else {
            return nil
        }

        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        
        guard let attributedString = try? NSMutableAttributedString(data: data, options: options, documentAttributes: nil) else {
            return nil
        }
        
        attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: UIFont.labelFontSize), range: NSMakeRange(0, attributedString.length))
        
        return attributedString
    }
    
}
