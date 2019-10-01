//
//  ParentId.swift
//  yahna
//
//  Created by Ernesto Badillo on 9/29/19.
//  Copyright © 2019 Ernesto Badillo. All rights reserved.
//

import Foundation

enum ParentId {
    
    case topStories
    case newStories
    case askStories
    case jobStories
    case item(id: Int64)
    
    var id: String {
        switch self {
        case .topStories: return "topstories"
        case .newStories: return "newstories"
        case .askStories: return "askstories"
        case .jobStories: return "jobstories"
        case .item(let id): return "\(id)"
        }
    }
}
