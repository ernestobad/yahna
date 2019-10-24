//
//  RefreshableViewModelBase.swift
//  yahna
//
//  Created by Ernesto Badillo on 10/22/19.
//  Copyright © 2019 Ernesto Badillo. All rights reserved.
//

import Foundation
import SwiftUI

class RefreshableViewModelBase : RefreshableViewModel {
    
    let parentId: ParentId
    
    @Published var state: ViewState = ViewState(isRefreshing: false, error: nil)
    
    @Published var contentOffset: CGPoint?
    
    var isEmpty: Bool { return true }
    
    var lastRefreshTime: Date?
    
    init(_ parentId: ParentId) {
        self.parentId = parentId
    }
    
    func onRefreshStarted() {
        self.state = ViewState(isRefreshing: true, error: nil)
    }
    
    func onRefreshCompleted(_ result: [Item]?, error: Error?) {
        self.state = ViewState(isRefreshing: false, error: error)
        self.lastRefreshTime = Date()
    }
}

