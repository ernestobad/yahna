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

class Item : Identifiable, Hashable {
    
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
    let attributedHNLink: NSAttributedString?
    
    var partsIds: [Int64]
    var kidsIds: [Int64]
    
    var parts: [Item]?
    var kids: [Item]?
    var all: [Item]?
    var idToIndexMap: [Int64: Int]?
    var depth: Int?
    
    var descendantsCount: Int64?
    
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
         descendantsCount: Int64? = nil,
         partsIds: [Int64]? = nil,
         kidsIds: [Int64]? = nil) {
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
        self.partsIds = partsIds ?? [Int64]()
        self.kidsIds = kidsIds ?? [Int64]()
        
        attributedText = Item.attributedText(from: text)
        attributedLink = Item.attributedLink(from: url, text: Item.urlWithoutProtocol(url ?? ""))
        attributedHNLink = Item.attributedLink(from: "https://news.ycombinator.com/item?id=\(id)", text: "HN", font: Fonts.caption.uiFont)
        
        all = [self]
        idToIndexMap = [self.id: all!.count-1]
    }
    
    var linkAttributes: [NSAttributedString.Key : Any]? {
        if let url = url, VisitedLinksManager.shared.isVisited(url) {
            return [NSAttributedString.Key.foregroundColor: UIColor.systemBlue.withAlphaComponent(0.6) ]
        } else {
            return nil
        }
    }
    
    convenience init?(jsonItem: JsonItem) {
        
        guard jsonItem.id > 0, let itemType = ItemType(rawValue: jsonItem.type) else {
            return nil
        }
        
        self.init(id: jsonItem.id,
                  deleted: jsonItem.deleted ?? false,
                  type: itemType,
                  by: jsonItem.by,
                  time: Date.init(timeIntervalSince1970: TimeInterval(jsonItem.time ?? 0)),
                  text: jsonItem.text,
                  dead: jsonItem.dead ?? false,
                  parent: jsonItem.parent,
                  poll: jsonItem.poll,
                  url: jsonItem.url,
                  score: jsonItem.score,
                  title: jsonItem.title,
                  descendantsCount: jsonItem.descendants,
                  partsIds: jsonItem.parts,
                  kidsIds: jsonItem.kids)
    }
    
    @discardableResult
    func calcDescendantCountsAndSortKids() -> Int {
        var count = 0
        self.kids?.forEach {
            count += 1
            count += $0.calcDescendantCountsAndSortKids()
        }
        self.kids?.sort {
            let lcount = $0.descendantsCount!
            let rcount = $1.descendantsCount!
            if lcount != rcount {
                return lcount > rcount
            } else {
                return $0.id > $1.id
            }
        }
        self.descendantsCount = Int64(count)
        return count
    }
    
    func setAllItemsAndDepths() {
        var allItems = [Item]()
        var idToIndexMap = [Int64: Int]()
        getAllItemsAndSetDepths(&allItems, &idToIndexMap, depth: 0)
        self.all = allItems
        self.idToIndexMap = idToIndexMap
    }
    
    private func getAllItemsAndSetDepths(_ allItems: inout [Item], _ idToIndexMap: inout [Int64: Int], depth: Int) {
        self.depth = depth
        allItems.append(self)
        idToIndexMap[self.id] = allItems.count-1
        parts?.forEach { $0.depth = depth+1; allItems.append($0); idToIndexMap[$0.id] = allItems.count-1 }
        kids?.forEach { $0.getAllItemsAndSetDepths(&allItems, &idToIndexMap, depth: depth+1) }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Item, rhs: Item) -> Bool {
        return lhs.id == rhs.id
    }
}

extension Item {
    
    var pointsString: String {
        let points = score ?? 0
        if points == 1 { return Strings.singlePointText.localizedString }
        else { return Strings.pointsFormat.localizedStringWithFormat(Int(points)) }
    }
    
    var commentsString: String {
        let comments = descendantsCount ?? 0
        if comments == 1 { return Strings.singleCommentText.localizedString }
        else { return Strings.commentsFormat.localizedStringWithFormat(Int(comments)) }
    }
    
    static func attributedLink(from url: String?, text: String, font: UIFont = Fonts.body.uiFont) -> NSAttributedString? {
        
        guard let url = url else {
            return nil
        }
        
        let attributes: [NSAttributedString.Key: Any] = [.link: url,
                                                         .font: font]
        
        return NSAttributedString(string: text, attributes: attributes)
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
                                      value: Fonts.body.uiFont,
                                      range: NSMakeRange(0, attributedString.length))
        
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor,
                                      value: UIColor.label,
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

extension Item {
    
    func getParent(of item: Item) -> Item? {
        
        guard let all = self.all, let parentId = item.parent, let parentIdx = self.idToIndexMap?[parentId], parentIdx < all.count else {
            return nil
        }
        
        return all[parentIdx]
    }
    
    func getSiblingsAndSiblingIndex(of item: Item) -> ([Item], Int)? {
        
        guard let parent = getParent(of: item) else {
            return nil
        }
        
        guard let kids = parent.kids, let childIdx = kids.firstIndex(where: { $0.id == item.id }) else {
            return nil
        }
        
        return (kids, childIdx)
    }
    
    func getNextSibling(of item: Item) -> Item? {
        guard let (siblings, idx) = getSiblingsAndSiblingIndex(of: item), idx < siblings.count-1 else {
            if let parent = getParent(of: item) {
                return getNextSibling(of: parent)
            }
            return nil
        }
        return siblings[idx+1]
    }
    
    func getPreviousSibling(of item: Item) -> Item? {
        guard let (siblings, idx) = getSiblingsAndSiblingIndex(of: item), idx > 0, idx < siblings.count else {
            if let parent = getParent(of: item) {
                return parent
            }
            return nil
        }
        return siblings[idx-1]
    }
}
