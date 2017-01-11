//
//  RandomName.swift
//  MarvelFaces
//
//  Created by Maxime De Greve on 10/01/2017.
//
//

import Foundation
import Vapor
import HTTP
import FluentMySQL

final class RandomName : NSObject{
    
    var firstName: String
    var lastName: String
    
    init(firstName: String, lastName: String) {
        self.firstName = firstName
        self.lastName = lastName
    }
    
    public static func generate(gender: FirstName.Gender) throws -> RandomName?{
        
        /* Never remove any row after seeding since this query assumes there are no 
        gaps inbetween the id sequence There is no other way right now to perfom a fast 
        query with random values other then the one written here. Using a ORDER BY RAND() 
        was slow and took about 80ms for a LIMIT 1. */
        
        if let mysql = drop.database?.driver as? MySQLDriver {
            let results = try mysql.raw("SELECT (SELECT name FROM random_last_names AS r1 JOIN (SELECT (RAND() * (SELECT MAX(id)FROM random_last_names)) AS id) AS r2 WHERE r1.id >= r2.id ORDER BY r1.id ASC LIMIT 1) as last_name, (SELECT name FROM random_first_names AS r1 JOIN (SELECT (RAND() * (SELECT MAX(id)FROM random_first_names)) AS id) AS r2 WHERE r1.id >= r2.id AND gender = \(gender.rawValue) ORDER BY r1.id ASC LIMIT 1) as first_name")
            let firstName = results.array?.first?.object?["first_name"]?.string
            let lastName = results.array?.first?.object?["last_name"]?.string
            let randomName = RandomName(firstName: firstName ?? "", lastName: lastName ?? "")
            return randomName
        }
        
        return nil
        
    }
    
}
