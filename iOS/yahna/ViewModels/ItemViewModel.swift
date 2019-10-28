//
//  ItemViewModel.swift
//  yahna
//
//  Created by Ernesto Badillo on 10/22/19.
//  Copyright © 2019 Ernesto Badillo. All rights reserved.
//

import Foundation
import Combine

class ItemAndCommentsViewModel : ItemViewModel {
    
    var stepOutDisabled: Bool = true
    
    var stepIntoDisabled: Bool = true
    
    var stepUpDisabled: Bool = true
    
    var stepDownDisabled: Bool = true
    
    var firstVisibleIndexPath: IndexPath? = nil {
        willSet {
            
            self.objectWillChange.send()
            
            var stepOutDisabled = true
            var stepIntoDisabled = true
            var stepUpDisabled = true
            var stepDownDisabled = true
            
            if let items = item.all, let newIndexPath = newValue, newIndexPath.row < items.count {
                let newItem = items[newIndexPath.row]
                if item.getNextSibling(of: newItem) != nil {
                    stepDownDisabled = false
                }
                if item.getPreviousSibling(of: newItem) != nil {
                    stepUpDisabled = false
                }
                if newItem.parent != nil {
                    stepOutDisabled = false
                }
                if !(newItem.kids?.isEmpty ?? true) {
                    stepIntoDisabled = false
                }
            }
            
            self.stepUpDisabled = stepUpDisabled
            self.stepIntoDisabled = stepIntoDisabled
            self.stepOutDisabled = stepOutDisabled
            self.stepDownDisabled = stepDownDisabled
        }
    }
    
    private(set) var scrollToIndexPathPublisher: AnyPublisher<IndexPath, Never>?
    
    private let scrollToIndexPathPassthroughSubject = PassthroughSubject<IndexPath, Never>()
    
    override init(_ item: Item) {
        super.init(item)
        scrollToIndexPathPublisher = scrollToIndexPathPassthroughSubject.eraseToAnyPublisher()
    }
 
    func onStepButtonSelected(_ direction: StepDirection) {
        
        guard let items = item.all, let idToIndexMap = item.idToIndexMap, let indexPath = firstVisibleIndexPath, indexPath.row < items.count  else {
            return
        }

        let currentItem = items[indexPath.row]

        switch direction {
        case .down:
            guard let nextSibling = item.getNextSibling(of: currentItem), let nextSiblingIndex = idToIndexMap[nextSibling.id] else {
                return
            }
            scrollToIndexPathPassthroughSubject.send(IndexPath(row: nextSiblingIndex, section: 0))
        case .up:
            guard let prevSibling = item.getPreviousSibling(of: currentItem), let prevSiblingIdIndex = idToIndexMap[prevSibling.id] else {
                return
            }
            scrollToIndexPathPassthroughSubject.send(IndexPath(row: prevSiblingIdIndex, section: 0))
        case .into:
            guard !(currentItem.kids?.isEmpty ?? true) else {
                return
            }
            guard let item = currentItem.kids?[0], let index = idToIndexMap[item.id] else {
                return
            }
            scrollToIndexPathPassthroughSubject.send(IndexPath(row: index, section: 0))
        case .out:
            guard let parentId = currentItem.parent, let parentIndex = idToIndexMap[parentId] else {
                return
            }
            scrollToIndexPathPassthroughSubject.send(IndexPath(row: parentIndex, section: 0))
        }
    }
}

class ItemViewModel : RefreshableViewModelBase {
    
    var item: Item
    
    override var isEmpty: Bool { item.kids?.isEmpty ?? true }
    
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
