//
//  ItemViewModel.swift
//  yahna
//
//  Created by Ernesto Badillo on 10/22/19.
//  Copyright © 2019 Ernesto Badillo. All rights reserved.
//

import Foundation

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
