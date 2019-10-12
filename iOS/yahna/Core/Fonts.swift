//
//  Fonts.swift
//  yahna
//
//  Created by Ernesto Badillo on 10/6/19.
//  Copyright © 2019 Ernesto Badillo. All rights reserved.
//

import Foundation
import SwiftUI

enum Fonts {
    case largeTitle
    case title
    case body
    case caption
    case comment
    
    var font: Font {
        switch self {
        case .comment: return Font.system(size: 16)
        case .body: return Font.system(size: 16)
        case .title: return Font.system(size: 16) // UIFont.labelFontSize ?
        case .largeTitle: return Font.system(size: 25)
        case .caption: return Font.system(size: 14)
        }
    }
    
    var uiFont: UIFont {
        switch self {
        case .comment: return UIFont.systemFont(ofSize: 16)
        case .body: return UIFont.systemFont(ofSize: 16)
        case .title: return UIFont.systemFont(ofSize: 16)
        case .largeTitle: return UIFont.systemFont(ofSize: 25)
        case .caption: return UIFont.systemFont(ofSize: 14)
        }
    }
}
