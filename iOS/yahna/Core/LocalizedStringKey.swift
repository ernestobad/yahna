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
    
    var localizedString: String {
        return NSLocalizedString(self.rawValue, comment: "")
    }
    
    var localizedStringKey: LocalizedStringKey {
        return LocalizedStringKey(self.rawValue)
    }
}
