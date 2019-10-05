//
//  ItemsDataModel.swift
//  yahna
//
//  Created by Ernesto Badillo on 10/1/19.
//  Copyright © 2019 Ernesto Badillo. All rights reserved.
//

import Foundation

class ItemsDataModel : ObservableObject {
    
    let parentId: ParentId
    
    let title: String?
    
    @Published var isRefreshing: Bool = false
    
    @Published var items: [Item] = [Item]() // todo: Item.children so we can have a comment hierarchy
    
    @Published var parentItem: Item?
    
    @Published var error: Error?
    
    init(_ parentId: ParentId, title: String? = nil) {
        self.parentId = parentId
        self.parentItem = nil
        self.title = title
    }
    
    init(_ parentItem: Item, title: String? = nil) {
        self.parentId = ParentId.item(id: parentItem.id)
        self.parentItem = parentItem
        self.title = title
    }
}
