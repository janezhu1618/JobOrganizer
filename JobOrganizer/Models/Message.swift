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
    var sender: String
}


struct MessageDictionaryKeys {
    static let sender = "Sender"
    static let messageBody = "Message Body"
    static let imageURL = "Image URL"
}
