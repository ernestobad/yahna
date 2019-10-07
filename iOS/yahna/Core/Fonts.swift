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
        case .comment: return Font.system(.caption)
        case .body: return Font.system(.body)
        case .title: return Font.system(.body)
        case .largeTitle: return Font.system(.largeTitle)
        case .caption: return Font.system(.footnote)
        }
    }
}
