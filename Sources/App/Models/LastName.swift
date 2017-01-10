//
//  FakeName.swift
//  MarvelFaces
//
//  Created by Maxime De Greve on 08/01/2017.
//
//

import Vapor
import HTTP
import FluentMySQL
import Foundation

final class LastName : Model{
    
    static var entity = "random_last_names"

    var id: Node?
    var name: String
    var exists: Bool = false
    
    init(name: String) {
        self.name = name
    }
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        name = try node.extract("name")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "name": name,
            ])
    }
    
    public static func revert(_ database: Database) throws {
        try database.delete("random_last_names")
    }
    
    public static func prepare(_ database: Database) throws {
        
        try database.create("random_last_names") { name in
            name.id()
            name.string("name", length: 200, optional: false, unique: true)
        }
                
    }
    
    public static func seed() {
        
        do {
            let namesCount = try LastName.query().count()
            if namesCount > 0{
                //return
            }
            
            let csvFileContents = try String(contentsOfFile: drop.resourcesDir + "/Data/LastNames.csv", encoding: .utf8)
            let csvLines = csvFileContents.components(separatedBy: "\r")
            for name in csvLines {
                var name = LastName(name:name)
                try name.save()
            }
            
        } catch let error {
            Swift.print(error)
        }
        
    }

}
