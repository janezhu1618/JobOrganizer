//
//  JOb.swift
//  JobOrganizer
//
//  Created by Jane Zhu on 2/25/19.
//  Copyright © 2019 JaneZhu. All rights reserved.
//

import Foundation

enum ApplicationPhase: String {
    case interested = "Interested"
    case applicationSent = "Applcation Sent"
    case phoneInterview = "Phone Interview"
    case inPersonInterview = "In-Person Interview"
    case whiteboarding = "Whiteboarding"
    case jobOffer = "Job Offer"
    case itsComplicated = "It's Complicated"
}

struct Job {
    var company: String = ""
    var position: String = ""
    var jobPostingURL: String = ""
    var notes: String = ""
    var applicationPhase = ""
    //    var applicationPhase: String
    var dateCreated: String = ""
    var lastUpdated: String = ""
    var contactPersonName: String = ""
    var contactPersonNumber: String = ""
    var contactPersonEmail: String = ""
    var userID: String = ""
//    var company: String
//    var position: String
//    var jobPostingURL: String?
//    var notes: [String]
//    var applicationPhase: ApplicationPhase
////    var applicationPhase: String
//    var dateCreated: String
//    var lastUpdated: String
//    var contactPersonName: String?
//    var contactPersonNumber: String?
//    var contactPersonEmail: String?
//    let userID: String
    //TODO: figure out a better way to get date
//    public var dateFormattedString: String {
//        let isoDateFormatter = ISO8601DateFormatter()
//        var formattedDate = lastUpdated
//        if let date = isoDateFormatter.date(from: lastUpdated) {
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "MMMM d, yyyy @ hh:mm a"
//            formattedDate = dateFormatter.string(from: date)
//        }
//        return formattedDate
//    }
    
    public var date: Date {
        let isoDateFormatter = ISO8601DateFormatter()
        var formattedDate = Date()
        if let date = isoDateFormatter.date(from: lastUpdated) {
            formattedDate = date
        }
        return formattedDate
    }
    

}
