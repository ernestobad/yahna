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
    case bestStories
    case newStories
    case askStories
    case showStories
    case jobStories
    case item(id: Int64)
    
    var id: String {
        switch self {
        case .topStories: return "topstories"
        case .bestStories: return "beststories"
        case .newStories: return "newstories"
        case .askStories: return "askstories"
        case .showStories: return "showstories"
        case .jobStories: return "jobstories"
        case .item(let id): return "\(id)"
        }
    }
    
    var title: String? {
        switch self {
        case .topStories: return Strings.topStoriesViewTitle.localizedString
        case .bestStories: return Strings.bestStoriesViewTitle.localizedString
        case .newStories: return Strings.newStoriesViewTitle.localizedString
        case .askStories: return Strings.askStoriesViewTitle.localizedString
        case .showStories: return Strings.showStoriesViewTitle.localizedString
        case .jobStories: return Strings.jobStoriesViewTitle.localizedString
        case .item(_): return nil
        }
    }
}
