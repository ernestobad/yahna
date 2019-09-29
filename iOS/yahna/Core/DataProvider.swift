//
//  DataProvider.swift
//  yahna
//
//  Created by Ernesto Badillo on 9/19/19.
//  Copyright © 2019 Ernesto Badillo. All rights reserved.
//

import Foundation
import Combine

class DataModel : ObservableObject {
    
    @Published var isLoading: Bool = false
    
    @Published var items: [Item] = [Item]()
    
    @Published var error: Error?
}

class DataProvider {
    
    enum DataProviderError : Error {
        case invalidItem
    }
    
    public var topStories = DataModel()
    
    public static let shared = DataProvider()
    
    func refreshTopStories() -> AnyCancellable {
        refreshDataModel(self.topStories, itemIdsPublisher: NetworkDataProvider.shared.getTopStories())
    }
    
    func refreshDataModel(_ dataModel: DataModel, itemIdsPublisher: AnyPublisher<[Int64], Error>) -> AnyCancellable {
        
        DispatchQueue.main.async { dataModel.isLoading = true }
        
        return itemIdsPublisher
            .flatMap({ (ids) -> AnyPublisher<[Item], Error> in self.getItems(ids: ids) })
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    dataModel.error = nil
                case .failure(let anError):
                    dataModel.error = anError
                }
                dataModel.isLoading = false
            }, receiveValue: { (items) in
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
