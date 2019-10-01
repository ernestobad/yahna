//
//  JsonItem.swift
//  yahna
//
//  Created by Ernesto Badillo on 9/29/19.
//  Copyright © 2019 Ernesto Badillo. All rights reserved.
//

import Foundation

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
