//
//  DataProvider.swift
//  yahna
//
//  Created by Ernesto Badillo on 9/19/19.
//  Copyright © 2019 Ernesto Badillo. All rights reserved.
//

import Foundation
import Combine

class DataProvider {
    
    enum DataProviderError : Error {
        case invalidItem
    }
    
    public static let shared = DataProvider()
    
    @discardableResult
    public func refreshViewModel<T : RefreshableViewModel>(_ viewModel: T) -> Cancellable {
        
        DispatchQueue.main.async { viewModel.onRefreshStarted() }
        
        let combinedPublisher: AnyPublisher<(Item?, [Item]), Error>
                
        let parentPublisher: AnyPublisher<Item?, Error>
        
        if case let ParentId.item(id: id) = viewModel.parentId {
            parentPublisher = NetworkDataProvider.shared.getItem(id: id)
                .tryMap { (jsonItem) -> Item? in
                    guard let item = Item(jsonItem: jsonItem) else { throw DataProviderError.invalidItem }
                    return item
            }.eraseToAnyPublisher()
        } else {
            parentPublisher = Just(nil as Item?).tryMap({ $0 }).eraseToAnyPublisher()
        }
        
        let itemsPublisher = NetworkDataProvider.shared.getItems(viewModel.parentId)
            .tryMap({ (jsonItems) -> [Item] in jsonItems.compactMap { (jsonItem) in Item(jsonItem: jsonItem) } })
            .eraseToAnyPublisher()
        
        combinedPublisher = parentPublisher
            .combineLatest(itemsPublisher)
            .eraseToAnyPublisher()
        
        var result: [Item]?
        
        return combinedPublisher
            .map({ (parent, items) -> [Item] in
                if let parent = parent {
                    var idToItemMap = [Int64: Item]()
                    idToItemMap[parent.id] = parent
                    items.forEach { idToItemMap[$0.id] = $0 }
                    idToItemMap.values.sorted(by: { $0.id < $1.id }).forEach {
                        if let parentId = $0.parent, let parent = idToItemMap[parentId] {
                            parent.kids.append($0)
                        }
                    }
                    return [parent]
                } else {
                    return items
                }
            })
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    viewModel.onRefreshCompleted(result, error: nil)
                case .failure(let anError):
                    viewModel.onRefreshCompleted(result, error: anError)
                }
            }, receiveValue: { refreshResult in
                result = refreshResult
            })
    }
}
