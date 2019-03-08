//
//  Message.swift
//  JobOrganizer
//
//  Created by Jane Zhu on 2/27/19.
//  Copyright © 2019 JaneZhu. All rights reserved.
//

import Foundation

struct Message {
    var messageBody: String
    var imageURL: String
    var senderID: String
    var senderEmail: String
    var timeStamp: String
    var dbReferenceDocumentId: String
    
    init(messageBody: String, imageURL: String, senderID: String, senderEmail: String, timeStamp: String, dbReferenceDocumentId: String) {
        self.messageBody = messageBody
        self.imageURL = imageURL
        self.senderID = senderID
        self.senderEmail = senderEmail
        self.timeStamp = timeStamp
        self.dbReferenceDocumentId = dbReferenceDocumentId
    }
    
    init(dict: [String: String]) {
        self.messageBody = dict[MessageDictionaryKeys.messageBody] ?? "no message body"
        self.imageURL = dict[MessageDictionaryKeys.imageURL] ?? "no iamgeURL"
        self.senderID = dict[MessageDictionaryKeys.senderID] ?? "no sender ID"
        self.senderEmail = dict[MessageDictionaryKeys.senderEmail] ?? "no email"
        self.timeStamp = dict[MessageDictionaryKeys.timeStamp] ?? "no timestamp"
        self.dbReferenceDocumentId = dict["dbReferenceDocumentId"] ?? "no dbRefrence"
    }
}


struct MessageDictionaryKeys {
    static let senderID = "Sender ID"
    static let senderEmail = "Sender Email"
    static let messageBody = "Message Body"
    static let imageURL = "Image URL"
    static let timeStamp = "Timestamp"
}
