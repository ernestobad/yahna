//
//  DataProvider.swift
//  yahna
//
//  Created by Ernesto Badillo on 9/19/19.
//  Copyright © 2019 Ernesto Badillo. All rights reserved.
//

import Foundation
import Combine

class ItemsDataModel : ObservableObject {
    
    let parentId: ParentId
    
    @Published var isRefreshing: Bool = false
    
    @Published var items: [Item] = [Item]()
    
    @Published var parentItem: Item?
    
    @Published var error: Error?
    
    init(_ parentId: ParentId) {
        self.parentId = parentId
        self.parentItem = nil
    }
    
    init(_ parentItem: Item) {
        self.parentId = ParentId.item(id: parentItem.id)
        self.parentItem = parentItem
    }
}

class DataProvider {
    
    enum DataProviderError : Error {
        case invalidItem
    }
    
    public static let shared = DataProvider()
    
    public func refreshDataModel(_ dataModel: ItemsDataModel) -> AnyCancellable {
        
        DispatchQueue.main.async { dataModel.isRefreshing = true }
        
        let combinedPublisher: AnyPublisher<(Item?, [Item]), Error>
                
        let parentPublisher: AnyPublisher<Item?, Error>
        
        if case let ParentId.item(id: id) = dataModel.parentId {
            parentPublisher = NetworkDataProvider.shared.getItem(id: id)
                .tryMap { (jsonItem) -> Item? in
                    guard let item = Item(jsonItem: jsonItem) else { throw DataProviderError.invalidItem }
                    return item
            }.eraseToAnyPublisher()
        } else {
            parentPublisher = Just(nil as Item?).tryMap({ $0 }).eraseToAnyPublisher()
        }
        
        let itemsPublisher = NetworkDataProvider.shared.getItems(dataModel.parentId)
            .tryMap({ (jsonItems) -> [Item] in jsonItems.compactMap { (jsonItem) in Item(jsonItem: jsonItem) } })
            .eraseToAnyPublisher()
        
        combinedPublisher = parentPublisher
            .combineLatest(itemsPublisher)
            .eraseToAnyPublisher()
        
        return combinedPublisher
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    dataModel.error = nil
                case .failure(let anError):
                    dataModel.error = anError
                }
                dataModel.isRefreshing = false
            }, receiveValue: { (parent, items) in
                dataModel.parentItem = parent
                dataModel.items = items
            })
    }
    
    private func getItems(ids: [Int64]) -> AnyPublisher<[Item], Error> {
        Just(ids)
            .receive(on: DispatchQueue.global())
            .tryMap { (ids) -> [Int64: Item] in try DatabaseManager.shared.get(ids: ids) }
            .flatMap { mapFromDb -> AnyPublisher<[Item], Error> in
                
                let missingIds = ids.filter { mapFromDb[$0] == nil }
                
                return Publishers.Sequence<[Int64], Error>(sequence: missingIds)
                    .flatMap { (id) -> AnyPublisher<JsonItem, Error> in NetworkDataProvider.shared.getItem(id: id) }
                    .tryMap({ (jsonItem) throws -> Item in
                        guard let item = Item(jsonItem: jsonItem) else {
                            throw DataProviderError.invalidItem
                        }
                        try? DatabaseManager.shared.save(item: item)
                        return item
                    })
                    .collect()
                    .map { (networkItems) -> [Item] in
                        
                        var mapFromNetwork = [Int64:Item]()
                        networkItems.forEach { mapFromNetwork[$0.id] = $0 }
                        
                        var result = [Item]()
                        for id in ids {
                            if let item = mapFromNetwork[id] {
                                result.append(item)
                            } else if let item = mapFromDb[id] {
                                result.append(item)
                            }
                        }
                        return result
                }
                .eraseToAnyPublisher()
                
        }.eraseToAnyPublisher()
    }
}
