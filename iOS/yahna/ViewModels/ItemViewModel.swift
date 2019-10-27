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
    
    var stepOutDisabled: Bool = false
    
    var stepIntoDisabled: Bool = false
    
    var stepUpDisabled: Bool = false
    
    var stepDownDisabled: Bool = false
    
    var firstVisibleIndexPath: IndexPath? = nil
    
    private(set) var scrollToIndexPublisher: AnyPublisher<Int, Never>?
    
    private let scrollToIndexPassthroughSubject = PassthroughSubject<Int, Never>()
    
    override init(_ item: Item) {
        super.init(item)
        scrollToIndexPublisher = scrollToIndexPassthroughSubject.eraseToAnyPublisher()
    }
 
    func onStepButtonSelected(_ direction: StepDirection) {
        // TODO:
//        guard let items = item.all, let indexPath = firstVisibleIndexPath, indexPath.row < items.count  else {
//            return
//        }
//
//        let currentItem = items[indexPath.row]
//
//        switch direction {
//        case .down: currentItem.par
//        case .up:
//        case .into:
//        case .out:
//        }
//
    }
}

class ItemViewModel : RefreshableViewModelBase {
    
    @Published var item: Item
    
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
