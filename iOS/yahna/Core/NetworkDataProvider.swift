//
//  DataProvider.swift
//  yahna
//
//  Created by Ernesto Badillo on 9/19/19.
//  Copyright © 2019 Ernesto Badillo. All rights reserved.
//

import Foundation
import Combine

struct JsonItem : Decodable {
    
    let id: Int64
    
    let deleted: Bool?
    
    let type: String
    
    let by: String?
    
    let time: Int64?
    
    let text: String?
    
    let dead: Bool?
    
    let parent: Int64?
    
    let poll: Int64?
    
    let kids: [Int64]?
    
    let url: String?
    
    let score: Int64?
    
    let title: String?
    
    let parts: [Int64]?
    
    let descendants: Int64?
}

class NetworkDataProvider {
    
    enum NetworkDataProviderError: Error {
        case noData
    }
    
    public static let shared = NetworkDataProvider()
    
    private init() {
        
    }
    
    private let topStoriesUrl = URL(string: "https://hacker-news.firebaseio.com/v0/topstories.json")!
    
    private func itemUrl(id: Int64) -> URL {
        URL(string: "https://hacker-news.firebaseio.com/v0/item/\(id).json")!
    }
    
    public func getTopStories() -> AnyPublisher<[Int64], Error> {
        URLSession.shared.dataTaskPublisher(for: topStoriesUrl)
            .map { $0.data }
            .decode(type: [Int64].self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    public func getItem(id: Int64) -> AnyPublisher<JsonItem, Error> {
        URLSession.shared.dataTaskPublisher(for: itemUrl(id: id))
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
