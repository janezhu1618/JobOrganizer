//
//  MessageBoard.swift
//  JobOrganizer
//
//  Created by Jane Zhu on 2/27/19.
//  Copyright © 2019 JaneZhu. All rights reserved.
//

import Foundation

struct MessageBoard {
    var title: String
    var description: String
    var creatorID: String
    var lastUpdated: String
    var dbReferenceDocumentId: String
    
    init(name: String, description: String, creatorID: String, lastUpdated: String, dbReferenceDocumentId: String) {
        self.title = name
        self.description = description
        self.creatorID = creatorID
        self.lastUpdated = lastUpdated
        self.dbReferenceDocumentId = dbReferenceDocumentId
    }
    
    init(dict: [String: String]) {
        self.title = dict[MessageBoardKeys.title] ?? "no title"
        self.description = dict[MessageBoardKeys.description] ?? "no description"
        self.creatorID = dict[MessageBoardKeys.creatorID] ?? "no creator ID"
        self.lastUpdated = dict[MessageBoardKeys.lastUpdated] ?? "no last updated time"
        self.dbReferenceDocumentId = dict[MessageBoardKeys.dbReferenceDocumentId] ?? "no dbReferenceDocumentId"
    }
    
    
    
}

struct MessageBoardKeys {
    static let title = "Title"
    static let description = "Description"
    static let creatorID = "Creator ID"
    static let lastUpdated = "Last Updated"
    static let dbReferenceDocumentId = "dbReferenceDocumentId"
}
