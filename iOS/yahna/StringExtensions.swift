//
//  StringExtensions.swift
//  yahna
//
//  Created by Ernesto Badillo on 10/23/19.
//  Copyright © 2019 Ernesto Badillo. All rights reserved.
//

import Foundation
import UIKit

extension String {
    
    func height(availableWidth: CGFloat, font: UIFont) -> CGFloat {
        let attributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font]
        return (self as NSString).boundingRect(with: CGSize(width: availableWidth,
                                                            height: CGFloat.greatestFiniteMagnitude),
                                               options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                               attributes: attributes,
                                               context: nil).size.height
    }
}
