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
    
    let topStories = ItemsViewModel(.topStories)
    let newStories = ItemsViewModel(.newStories)
    let askStories = ItemsViewModel(.askStories)
    let showStories = ItemsViewModel(.showStories)
    let jobStories = ItemsViewModel(.jobStories)
    
    private var itemsViewModelsCache: NSCache<NSNumber, ItemViewModel> = {
        let cache = NSCache<NSNumber, ItemViewModel>()
        cache.countLimit = 100
        return cache
    }()
    
    public func itemViewModel(_ item: Item) -> ItemViewModel {
        if let vm = itemsViewModelsCache.object(forKey: item.id as NSNumber) {
            return vm
        } else {
            let vm = ItemViewModel(item)
            itemsViewModelsCache.setObject(vm, forKey: item.id as NSNumber)
            return vm
        }
    }
    
    @discardableResult
    public func refreshViewModel<T : RefreshableViewModel>(_ viewModel: T, force: Bool = false) -> AnyPublisher<T, Never> {
        
        assert(Thread.isMainThread)
        
        if !force,
            viewModel.state.error == nil,
            let lastRefreshTime = viewModel.lastRefreshTime,
            Date().timeIntervalSince(lastRefreshTime) < TimeInterval(120) {
            return Just(viewModel).eraseToAnyPublisher()
        }
        
        if !force,
            viewModel.state.isRefreshing {
            return Just(viewModel).eraseToAnyPublisher()
        }
        
        viewModel.onRefreshStarted()
        
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
        
        
        let finalPublisher = combinedPublisher
            .map({ (parent, items) -> [Item] in
                if let parent = parent {
                    var idToItemMap = [Int64: Item]()
                    idToItemMap[parent.id] = parent
                    items.forEach { idToItemMap[$0.id] = $0 }
                    idToItemMap.values.forEach {
                        if let parentId = $0.parent, let parent = idToItemMap[parentId] {
                            if parent.kids == nil {
                                parent.kids = [Item]()
                            }
                            parent.kids?.append($0)
                        }
                    }
                    parent.calcDescendantCountsAndSortKids()
                    parent.setAllItemsAndDepths()
                    return [parent]
                } else {
                    return items
                }
            }).receive(on: RunLoop.main)
            
        
        return Future<T, Never> { promise in
            _ = finalPublisher
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        viewModel.onRefreshCompleted(result, error: nil)
                    case .failure(let anError):
                        viewModel.onRefreshCompleted(result, error: anError)
                    }
                    promise(.success(viewModel))
                }, receiveValue: { refreshResult in
                    result = refreshResult
                })
        }.eraseToAnyPublisher()
    }
}
