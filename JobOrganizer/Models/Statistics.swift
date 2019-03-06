//
//  Statistics.swift
//  JobOrganizer
//
//  Created by Jane Zhu on 3/6/19.
//  Copyright © 2019 JaneZhu. All rights reserved.
//

import Foundation

class Statistics {
    private static var statistics = [Int]()
    
    static func setStatistics(statistics: [Int]) {
        self.statistics = statistics
    }
    
    static func getStatistics() -> [Int] {
        return statistics
    }
}
