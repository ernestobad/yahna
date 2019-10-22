//
//  ItemsViewModel.swift
//  yahna
//
//  Created by Ernesto Badillo on 10/1/19.
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

class RefreshableViewModelBase : RefreshableViewModel {
    
    let parentId: ParentId
    
    @Published var state: ViewState = ViewState(isRefreshing: false, error: nil)
    
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

class ItemsViewModel : RefreshableViewModelBase {
    
    @Published var items: [Item] = [Item]()
    
    @Published var contentOffset: CGPoint?
    
    override var isEmpty: Bool { items.isEmpty }
    
    override init(_ parentId: ParentId) {
        super.init(parentId)
    }
    
    override func onRefreshCompleted(_ result: [Item]?, error: Error?) {
        if let items = result {
            self.items = items
        }
        super.onRefreshCompleted(result, error: error)
    }
}

class ItemViewModel : RefreshableViewModelBase {
    
    @Published var item: Item
    
    override var isEmpty: Bool { item.kids.isEmpty }
    
    init(_ item: Item) {
        self.item = item
        super.init(ParentId.item(id: item.id))
    }
    
    override func onRefreshCompleted(_ result: [Item]?, error: Error?) {
        if let item = result?.first {
            self.item = item
        }
        super.onRefreshCompleted(result, error: error)
    }
}
