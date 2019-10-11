//
//  Item.swift
//  yahna
//
//  Created by Ernesto Badillo on 9/18/19.
//  Copyright © 2019 Ernesto Badillo. All rights reserved.
//

import Foundation
import UIKit

enum ItemType: String {
    case job
    case story
    case comment
    case poll
    case pollopt
}

class Item : Identifiable {
    
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
    
    let attributedText: NSAttributedString?
    let attributedLink: NSAttributedString?
    
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
        
        attributedText = Item.attributedText(from: text)
        attributedLink = Item.attributedLink(from: url)
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
        
        attributedText = Item.attributedText(from: text)
        attributedLink = Item.attributedLink(from: url)
    }
}

extension Item {
    
    
    static func attributedLink(from url: String?) -> NSAttributedString? {
        
        guard let url = url else {
            return nil
        }
        
        let attributes: [NSAttributedString.Key: Any] = [.link: url,
                                                         .font: UIFont.systemFont(ofSize: UIFont.labelFontSize),
                                                         .foregroundColor: UIColor.systemTeal]
        
        return NSAttributedString(string: urlWithoutProtocol(url), attributes: attributes)
    }
    
    static func attributedText(from encodedText: String?) -> NSAttributedString? {
        
        guard let str = encodedText else {
            return nil
        }
        
        guard let data = str.data(using: .utf8) else {
            return nil
        }

        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        
        guard let attributedString = try? NSMutableAttributedString(data: data, options: options, documentAttributes: nil) else {
            return nil
        }
        
        attributedString.addAttribute(NSAttributedString.Key.font,
                                      value: UIFont.systemFont(ofSize: UIFont.labelFontSize),
                                      range: NSMakeRange(0, attributedString.length))
        
        if attributedString.string.hasSuffix("\n") {
            attributedString.deleteCharacters(in: NSMakeRange(attributedString.length-1, 1))
        }
        
        return attributedString
    }
    
    static func urlWithoutProtocol(_ url: String) -> String {
        
        let prefixesToRemove = ["http://www.", "https://www.", "https://", "http://"]
        
        for prefix in prefixesToRemove {
            if url.starts(with: prefix) {
                let idx = url.index(url.startIndex, offsetBy: prefix.count)
                return String(url.suffix(from: idx))
            }
        }
        
        return url
    }
}
