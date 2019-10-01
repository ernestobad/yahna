//
//  DatabaseManager.swift
//  yahna
//
//  Created by Ernesto Badillo on 9/18/19.
//  Copyright © 2019 Ernesto Badillo. All rights reserved.
//

import Foundation
import SQLite
import Combine

class DatabaseManager {
    
    private let databasePath = "database/db.sqlite3"
    
    private let itemsTable = Table("items")
    
    // The item's unique id.
    private let idCol = Expression<Int64>("id")
    
    // true if the item is deleted.
    private let deletedCol = Expression<Bool>("deleted")
    
    // The type of item. One of "job", "story", "comment", "poll", or "pollopt".
    private let typeCol = Expression<String>("type")
    
    // The username of the item's author.
    private let byCol = Expression<String?>("by")
    
    // Creation date of the item, in Unix Time.
    private let timeCol = Expression<Int64>("time")
    
    // The comment, story or poll text. HTML.
    private let textCol = Expression<String?>("text")
    
    // true if the item is dead.
    private let deadCol = Expression<Bool>("dead")
    
    // The comment's parent: either another comment or the relevant story.
    private let parentCol = Expression<Int64?>("parent")
    
    // the order this item appears in the parent's kids list
    private let childOrderCol = Expression<Int64?>("child_order")
    
    // The pollopt's associated poll.
    private let pollCol = Expression<Int64?>("poll")
    
    // The order this poll option appears in the poll's parts list.s
    private let pollOptionOrderCol = Expression<Int64?>("pollopt_order")
    
    // The URL of the story.
    private let urlCol = Expression<String?>("url")
    
    // The story's score, or the votes for a pollopt.
    private let scoreCol = Expression<Int64?>("score")
    
    // The title of the story, poll or job.
    private let titleCol = Expression<String?>("title")
    
    // In the case of stories or polls, the total comment count.
    private let descendantsCountCol = Expression<Int64?>("descendants_count")
    
    // TODO: views table.
    
    private var db: Connection?
    
    private let concurrentQueue = DispatchQueue(label: "DatabaseManager.concurrentQueue", attributes: .concurrent)
    
    public static let shared : DatabaseManager = DatabaseManager()
    
    func getConnection() throws -> Connection {
        
        if let db = concurrentQueue.sync(execute: { () -> Connection? in self.db }) {
            return db
        }
        
        return try concurrentQueue.sync(flags: DispatchWorkItemFlags.barrier) { () throws -> Connection in
            
            if let db = self.db {
                return db
            }
            
            let baseUrl = FileManager.default.urls(for: FileManager.SearchPathDirectory.cachesDirectory,
                                                   in: FileManager.SearchPathDomainMask.userDomainMask).first!
            
            let dbUrl = baseUrl.appendingPathComponent(databasePath)
            
            try FileManager.default.createDirectory(atPath: dbUrl.deletingLastPathComponent().path,
                                                    withIntermediateDirectories: true,
                                                    attributes: nil)
            
            let db = try Connection(dbUrl.path)
            Log.logger.info("Opened DB at \(dbUrl.path)")
            self.db = db
            return db
        }
    }
    
    func createDB() throws {
        
        let db = try getConnection()
        
        try db.run(itemsTable.create(ifNotExists: true) { t in
            t.column(idCol, primaryKey: true)
            t.column(deletedCol)
            t.column(typeCol)
            t.column(byCol)
            t.column(timeCol)
            t.column(textCol)
            t.column(deadCol)
            t.column(parentCol)
            t.column(childOrderCol)
            t.column(pollCol)
            t.column(pollOptionOrderCol)
            t.column(urlCol)
            t.column(scoreCol)
            t.column(titleCol)
            t.column(descendantsCountCol)
            
            t.foreignKey(parentCol, references: itemsTable, idCol)
            t.foreignKey(pollCol, references: itemsTable, idCol)
        })
        
        try db.run(itemsTable.createIndex(parentCol, childOrderCol, unique: false, ifNotExists: true))
        try db.run(itemsTable.createIndex(pollCol, pollOptionOrderCol, unique: false, ifNotExists: true))
    }
    
    func save(item: Item) throws {
        
        try getConnection().run(itemsTable.insert(or: .replace,
                                     idCol <- item.id,
                                     deletedCol <- item.deleted,
                                     typeCol <- item.type.rawValue,
                                     byCol <- item.by,
                                     timeCol <- Int64(item.time.timeIntervalSince1970),
                                     textCol <- item.text,
                                     deadCol <- item.dead,
                                     parentCol <- item.parent,
                                     pollCol <- item.poll,
                                     urlCol <- item.url,
                                     scoreCol <- item.score,
                                     titleCol <- item.title,
                                     descendantsCountCol <- item.descendantsCount))
    }
        
    func get(id: Int64) throws -> Item? {
        
        guard let row = try getConnection().pluck(itemsTable.filter(idCol == id)) else {
            return nil
        }
        
        return item(from: row)
    }
    
    func get(ids: [Int64]) throws -> [Int64: Item] {
        
        let db = try getConnection()
        
        var map = [Int64:Item]()
        for idsChunk in ids.chunked(into: 100) {
            for row in try db.prepare(itemsTable.filter(idsChunk.contains(idCol))) {
                if let item = item(from: row) {
                    map[item.id] = item
                }
            }
        }
        return map
    }
    
    private func item(from row: SQLite.Row) -> Item? {
        
        guard row[idCol] > 0 else {
            Log.logger.error("Invalid id")
            return nil
        }
        
        guard let type = ItemType.init(rawValue: row[typeCol]) else {
            Log.logger.error("Invalid type")
            return nil
        }
        
        return Item(id: row[idCol],
                    deleted: row[deletedCol],
                    type: type,
                    by: row[byCol],
                    time: Date.init(timeIntervalSince1970: TimeInterval(row[timeCol])),
                    text: row[textCol],
                    dead: row[deadCol],
                    parent: row[parentCol],
                    childOrder: row[childOrderCol],
                    poll: row[pollCol],
                    pollOptionOrder: row[pollOptionOrderCol],
                    url: row[urlCol],
                    score: row[scoreCol],
                    title: row[titleCol],
                    descendantsCount: row[descendantsCountCol])
    }
    
}
