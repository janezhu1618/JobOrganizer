//
//  ViewController+Dates.swift
//  JobOrganizer
//
//  Created by Jane Zhu on 3/4/19.
//  Copyright © 2019 JaneZhu. All rights reserved.
//

import UIKit

extension UIViewController {
    public func getTimestamp() -> String {
        let date = Date()
        let isoDateFormatter = ISO8601DateFormatter()
        isoDateFormatter.formatOptions = [.withFullDate,
                                          .withFullTime,
                                          .withInternetDateTime,
                                          .withTimeZone,
                                          .withDashSeparatorInDate]
        let timeStamp = isoDateFormatter.string(from: date)
        return timeStamp
    }
    
    public func getFormattedDate(date: String) -> String {
        let isoDateFormatter = ISO8601DateFormatter()
        var formattedDate = Date()
        if let date = isoDateFormatter.date(from: date) {
            formattedDate = date
        }
        return formattedDate.description
    }
    
    public func getReadableDate(fromTimestamp timestamp: String) -> String {
        let isoDateFormatter = ISO8601DateFormatter()
        var formattedDate = timestamp
        if let date = isoDateFormatter.date(from: timestamp) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM d, h:mm a"
            formattedDate = dateFormatter.string(from: date)
        }
        return formattedDate
    }
}
