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
    
    private let visitedLinksTable = Table("visited_urls")
    
    private let urlCol = Expression<String>("url")
    
    private let timeCol = Expression<Int64>("time")
    
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
        
        try db.run(visitedLinksTable.create(ifNotExists: true) { t in
            t.column(urlCol, primaryKey: true)
            t.column(timeCol)
        })
        
        try db.run(visitedLinksTable.createIndex(timeCol, unique: false, ifNotExists: true))
    }
    
    func insertOrUpdateVisitedUrl(_ url: String, time: Date) throws {
        try getConnection().run(visitedLinksTable.insert(or: .replace,
                                                         urlCol <- url,
                                                         timeCol <- Int64(time.timeIntervalSince1970)))
    }
    
    func queryVisitedUrls(lm: Int) throws -> [String] {
        var result = [String]()
        for row in try getConnection().prepare(visitedLinksTable.order(timeCol).limit(lm)) {
            result.append(row[urlCol])
        }
        return result
    }
}
