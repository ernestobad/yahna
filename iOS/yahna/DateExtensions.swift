//
//  DateExtensions.swift
//  yahna
//
//  Created by Ernesto Badillo on 9/29/19.
//  Copyright © 2019 Ernesto Badillo. All rights reserved.
//

import Foundation

extension Date {
    
    private static let oneMinute = TimeInterval(60)
    private static let oneHour = TimeInterval(60*60)
    private static let oneDay = TimeInterval(60*60*24)
    private static let oneWeek = TimeInterval(60*60*24*7)
    
    private static var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        dateFormatter.locale = Locale.current
        return dateFormatter
    }()
    
    func toTimeString() -> String {
        let now = Date()
        let interval = now.timeIntervalSince(self)
        switch interval {
        case let i where i < 1:
            return "now"
        case let i where i >= 1 && i < Date.oneMinute:
            let secs = Int(i)
            return "\(secs)s"
        case let i where i >= Date.oneMinute && i < Date.oneHour:
            let mins = Int(i/Date.oneMinute)
            return "\(mins)m"
        case let i where i >= Date.oneHour && i < Date.oneDay:
            let hrs = Int(i/Date.oneHour)
            return "\(hrs)h"
        case let i where i >= Date.oneDay && i < Date.oneWeek:
            let days = Int(i/Date.oneDay)
            return "\(days)d"
        default:
            return Date.dateFormatter.string(from: self)
        }
    }
    
}
