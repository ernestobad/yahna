//
//  VisitedLinksManager.swift
//  yahna
//
//  Created by Ernesto Badillo on 10/22/19.
//  Copyright © 2019 Ernesto Badillo. All rights reserved.
//

import Foundation

class VisitedLinksManager {
    
    // used to synchronize access to visitedLinks.
    let syncQueue = DispatchQueue(label: "VisitedLinksManager", attributes: .concurrent)
    
    private init() {
        
    }
    
    public static var shared = VisitedLinksManager()
    
    var visitedLinks: Set<String>?
    
    public func load() {
        DispatchQueue.global(qos: .default).async {
            if let urls = try? DatabaseManager.shared.queryVisitedUrls(lm: 1000) {
                self.syncQueue.async(flags: .barrier) {
                    self.visitedLinks = Set<String>(urls)
                }
            }
        }
    }
    
    public func isVisited(_ url: String) -> Bool {
        var result: Bool = false
        syncQueue.sync {
            result = self.visitedLinks?.contains(url) ?? false
        }
        return result
    }
    
    public func markAsVisited(_ url: String) {
        syncQueue.async(flags: .barrier) {
            self.visitedLinks?.insert(url)
        }
        DispatchQueue.global(qos: .default).async {
            try? DatabaseManager.shared.insertOrUpdateVisitedUrl(url, time: Date())
        }
    }
}
