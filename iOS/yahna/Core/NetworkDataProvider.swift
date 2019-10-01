//
//  NetworkDataProvider.swift
//  yahna
//
//  Created by Ernesto Badillo on 9/19/19.
//  Copyright © 2019 Ernesto Badillo. All rights reserved.
//

import Foundation
import Combine

class NetworkDataProvider {
        
    enum NetworkDataProviderError: Error {
        case noData
    }
    
    public static let shared = NetworkDataProvider()
    
    private init() {
        
    }
    
    private let topStoriesIdsUrl = URL(string: "https://hacker-news.firebaseio.com/v0/topstories.json")!
    
    private func itemsUrl(_ parentId: String) -> URL {
        URL(string: "https://4iaeuw8835.execute-api.us-west-2.amazonaws.com/beta/items?id=\(parentId)")!
    }
    
    private func itemUrl(_ id: Int64) -> URL {
        URL(string: "https://hacker-news.firebaseio.com/v0/item/\(id).json")!
    }
    
    public func getTopStoriesIds() -> AnyPublisher<[Int64], Error> {
        URLSession.shared.dataTaskPublisher(for: topStoriesIdsUrl)
            .map { $0.data }
            .decode(type: [Int64].self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    public func getItems(_ parentId: ParentId) -> AnyPublisher<[JsonItem], Error> {
        URLSession.shared.dataTaskPublisher(for: itemsUrl(parentId.id))
            .map { $0.data }
            .decode(type: [JsonItem].self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    public func getItem(id: Int64) -> AnyPublisher<JsonItem, Error> {
        URLSession.shared.dataTaskPublisher(for: itemUrl(id))
            .map { $0.data }
            .mapError({ (error) -> Error in
                print("--- Error: \(error)")
                return error
            })
            .decode(type: JsonItem.self, decoder: JSONDecoder())
            .mapError({ (error) -> Error in
                print("--- Error: \(error)")
                return error
            })
            .eraseToAnyPublisher()
    }
    
    public func getItems(ids: [Int64]) -> AnyPublisher<[JsonItem], Error> {
        Publishers.Sequence<[Int64], Error>(sequence: ids)
            .flatMap { (id) -> AnyPublisher<JsonItem, Error> in self.getItem(id: id) }
            .collect()
            .eraseToAnyPublisher()
    }
}
