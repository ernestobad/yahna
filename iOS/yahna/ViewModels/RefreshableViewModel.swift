//
//  RefreshableViewModel.swift
//  yahna
//
//  Created by Ernesto Badillo on 10/22/19.
//  Copyright © 2019 Ernesto Badillo. All rights reserved.
//

import Foundation
import SwiftUI

struct ViewState {
    
    let isRefreshing: Bool
    
    let error: Error?
}

protocol RefreshableViewModel : ObservableObject {
    
    var parentId: ParentId { get }
    
    var state: ViewState { get }
    
    var isEmpty: Bool { get }
    
    var lastRefreshTime: Date? { get }
    
    func onRefreshStarted()
    
    func onRefreshCompleted(_ result: [Item]?, error: Error?)
}
