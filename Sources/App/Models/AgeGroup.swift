//
//  File.swift
//
//
//  Created by Maxime De Greve on 22/07/2021.
//

import Vapor

enum AgeGroup: String, Codable, CaseIterable {
    case baby = "baby" // 0-1
    case toddler = "toddler" // 1-4
    case child = "child" // 4-10
    case teenager = "teenager" // 10-17
    case youngAdult = "young_adult" // 18-40
    case middleAdult = "middle_adult" //40-64
    case oldAdult = "old_adult" //65+
}
