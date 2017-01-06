//
//  FakeGenerator.swift
//  MarvelFaces
//
//  Created by Maxime De Greve on 21/12/2016.
//
//

import Vapor
import Foundation

final class FakeGenerator {
    
    enum Gender: String {
        case male = "male"
        case female = "female"
        case other = "other"
    }

    static func firstName(for gender: Gender) -> String {
        do {
			
			let documentPath: String
			
			switch gender {
			case .male:
				documentPath = "/Data/FirstNamesMale.txt"
			case .female:
				documentPath = "/Data/FirstNamesFemale.txt"
			case .other:
				documentPath = "/Data/FirstNamesOther.txt"
			}
            
            let csvFileContents = try String(contentsOfFile: drop.resourcesDir + documentPath, encoding: .utf8)
            let csvLines = csvFileContents.components(separatedBy: "\n")
            var names = [String]()
            for name in csvLines {
                names.append(name)
            }
            
            let randomInt = Int.random(min: 0, max: names.count)
            return names[randomInt]
            
        } catch let error {
            Swift.print(error)
        }
        
        return ""
    }
    
    static func lastName() -> String {
        do {
            let csvFileContents = try String(contentsOfFile: drop.resourcesDir + "/Data/LastNames.csv", encoding: .utf8)
            let csvLines = csvFileContents.components(separatedBy: "\r")
            var names = [String]()
            for name in csvLines {
                names.append(name)
            }
            
            let randomInt = Int.random(min: 0, max: names.count)
            return names[randomInt]
        } catch let error {
            Swift.print(error)
        }
        
        return ""
    }
}
