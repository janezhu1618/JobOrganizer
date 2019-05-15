//
//  Job.swift
//  JobOrganizer
//
//  Created by Jane Zhu on 2/8/19.
//  Copyright © 2019 JaneZhu. All rights reserved.
//

import Foundation

struct Job: Codable {
    let companyName: String
    var position: String
    var applicationStatus: String
    var jobDescription: String
    var notes: String
}
