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
        case Male = "male"
        case Female = "female"
        case Other = "other"
    }

    static func firstName(gender: Gender) -> String{
        do {
            
            var documentPath = "/Data/FirstNamesOther.txt"
            if gender == .Male{
                documentPath = "/Data/FirstNamesMale.txt"
            } else if gender == .Female{
                documentPath = "/Data/FirstNamesFemale.txt"
            }
            
            let csvFileContents = try String(contentsOfFile: drop.resourcesDir + documentPath, encoding: String.Encoding.utf8)
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
    
    static func lastName() -> String{
        do {
            let csvFileContents = try String(contentsOfFile: drop.resourcesDir + "/Data/LastNames.csv", encoding: String.Encoding.utf8)
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
