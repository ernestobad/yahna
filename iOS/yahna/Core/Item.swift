//
//  Item.swift
//  yahna
//
//  Created by Ernesto Badillo on 9/18/19.
//  Copyright © 2019 Ernesto Badillo. All rights reserved.
//

import Foundation

enum ItemType: String {
    case job
    case story
    case comment
    case poll
    case pollopt
}

struct Item : Identifiable {
    
    let id: Int64
    let deleted: Bool
    let type: ItemType
    let by: String?
    let time: Date
    let text: String?
    let dead: Bool
    let parent: Int64?
    let poll: Int64?
    let url: String?
    let score: Int64?
    let title: String?
    
    var partsIds = [Int64]()
    var kidsIds = [Int64]()
    
    var parts = [Item]()
    var kids = [Item]()
    
    let descendantsCount: Int64?
    
    init(id: Int64,
         deleted: Bool,
         type: ItemType,
         by: String?,
         time: Date,
         text: String?,
         dead: Bool,
         parent: Int64?,
         poll: Int64?,
         url: String?,
         score: Int64?,
         title: String?,
         descendantsCount: Int64?) {
        self.id = id
        self.deleted = deleted
        self.type = type
        self.by = by
        self.time = time
        self.text = text
        self.dead = dead
        self.parent = parent
        self.poll = poll
        self.url = url
        self.score = score
        self.title = title
        self.descendantsCount = descendantsCount
    }
    
    init?(jsonItem: JsonItem) {
        
        guard jsonItem.id > 0, let itemType = ItemType(rawValue: jsonItem.type) else {
            return nil
        }
        
        id = jsonItem.id
        deleted = jsonItem.deleted ?? false
        type = itemType
        by = jsonItem.by
        time = Date.init(timeIntervalSince1970: TimeInterval(jsonItem.time ?? 0))
        text = jsonItem.text
        dead = jsonItem.dead ?? false
        parent = jsonItem.parent
        poll = jsonItem.poll
        url = jsonItem.url
        score = jsonItem.score
        title = jsonItem.title
        descendantsCount = jsonItem.descendants
        partsIds = jsonItem.parts ?? [Int64]()
        kidsIds = jsonItem.kids ?? [Int64]()
    }
    
    var domain: String {
        guard let urlString = self.url,
            let url = URL(string: urlString),
            let host = url.host else {
                return ""
        }
        
        let tokens = host.split(separator: Character("."))
        
        guard tokens.count >= 2 else {
            return ""
        }
        
        return "\(tokens[tokens.count-2]).\(tokens[tokens.count-1])"
    }
    
    var urlWithoutProtocol: String {
        
        guard let urlString = self.url else {
            return ""
        }
        
        let httpPrefix = "http://"
        let httpsPrefix = "https://"
        
        if urlString.starts(with: httpPrefix) {
            let idx = urlString.index(urlString.startIndex, offsetBy: httpPrefix.count)
            return String(urlString.suffix(from: idx))
        } else if urlString.starts(with: httpsPrefix) {
            let idx = urlString.index(urlString.startIndex, offsetBy: httpsPrefix.count)
            return String(urlString.suffix(from: idx))
        } else {
            return urlString
        }
    }
}
