//
//  FakeName.swift
//  MarvelFaces
//
//  Created by Maxime De Greve on 08/01/2017.
//
//

import Vapor
import HTTP
import Fluent
import FluentMySQL
import Foundation

final class FirstName : Model{
    
    static var entity = "random_first_names"
    
    enum Gender: Int {
        case male = 1
        case female = 2
        case all = 3
    }
    
    var id: Node?
    var name: String
    var gender: Int
    var exists: Bool = false
    
    init(name: String, gender: Gender) {
        self.name = name
        self.gender = gender.rawValue
    }
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        name = try node.extract("name")
        gender = try node.extract("gender")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "name": name,
            "gender": gender
            ])
    }

    public static func revert(_ database: Database) throws {
        try database.delete("random_first_names")
    }
    
    public static func prepare(_ database: Database) throws {
        
        try database.create("random_first_names") { name in
            name.id()
            name.string("name", length: 200, optional: false, unique: false)
            name.int("gender", optional: false)
        }

    }
    
    public static func seed(){
        
        do {
            
            let namesCount = try FirstName.query().count()
            if namesCount > 0{
                return
            }
            
            seedMale()
            seedFemale()
            
            Swift.print("Seeding all first names finished.")
            
        } catch let error {
            Swift.print(error)
        }
    
    }
    
    static func seedMale() {
        
        do {
            
            let documentPath = "/Data/FirstNamesMale.txt"
            let csvFileContents = try String(contentsOfFile: drop.resourcesDir + documentPath, encoding: .utf8)
            let csvLines = csvFileContents.components(separatedBy: "\n")
            for name in csvLines {
                if name.isEmpty == false {
                    var name = FirstName(name:name,gender:Gender.male)
                    try name.save()
                }
            }
        } catch let error {
            Swift.print(error)
        }
        
    }
    
    static func seedFemale() {
        
        do {

            let documentPath = "/Data/FirstNamesFemale.txt"
            let csvFileContents = try String(contentsOfFile: drop.resourcesDir + documentPath, encoding: .utf8)
            let csvLines = csvFileContents.components(separatedBy: "\n")
            for name in csvLines {
                if name.isEmpty == false {
                    var name = FirstName(name:name,gender:Gender.female)
                    try name.save()
                }
            }
        } catch let error {
            Swift.print(error)
        }
        
    }
    
}
