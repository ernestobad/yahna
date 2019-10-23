//
//  ItemsViewModel.swift
//  yahna
//
//  Created by Ernesto Badillo on 10/1/19.
//  Copyright © 2019 Ernesto Badillo. All rights reserved.
//

import Foundation
import SwiftUI

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

