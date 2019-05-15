//
//  User.swift
//  JobOrganizer
//
//  Created by Jane Zhu on 2/27/19.
//  Copyright © 2019 JaneZhu. All rights reserved.
//

import Foundation

struct JobOrganizerUser {
    let username: String?
    let imageURL: String?
    
    init(dict: [String: Any]) {
        self.username = dict["username"] as? String ?? "no username"
        self.imageURL = dict["imageURL"] as? String ?? "no imageURL"
    }
}

struct JobOrganizerUserKeys {
    static let jobOrganizerUsers = "JobOrganizerUsers"
}
