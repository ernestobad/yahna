//
//  LocalizedStringKey.swift
//  yahna
//
//  Created by Ernesto Badillo on 10/2/19.
//  Copyright © 2019 Ernesto Badillo. All rights reserved.
//

import Foundation
import SwiftUI

enum Strings: String {
    
    case topStoriesViewTitle
    case bestStoriesViewTitle
    case newStoriesViewTitle
    case askStoriesViewTitle
    case showStoriesViewTitle
    case jobStoriesViewTitle
    
    case closeWebViewButtonTitle
    
    case errorMessage
    case emptyViewMessage
    
    case pointsFormat
    case singlePointText
    case commentsFormat
    case singleCommentText
    
    var localizedString: String {
        return NSLocalizedString(self.rawValue, comment: "")
    }
    
    var localizedStringKey: LocalizedStringKey {
        return LocalizedStringKey(self.rawValue)
    }
    
    func localizedStringWithFormat(_ args: CVarArg...) -> String {
        let format = localizedString
        
        let result = withVaList(args) {
            (NSString(format: format, locale: NSLocale.current, arguments: $0) as String)
        }
        
        return result
    }
}
