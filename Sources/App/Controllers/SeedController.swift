//
//  SeedController.swift
//  MarvelFaces
//
//  Created by Maxime De Greve on 09/01/2017.
//
//

import Vapor
import Foundation
import HTTP

final class SeedController {
    
    func addRoutes(drop: Droplet) {
        drop.get("seed", handler: seed)
    }
    
    func seed(request: Request) throws -> ResponseRepresentable {
        FirstName.seedMale()
        FirstName.seedFemale()
        LastName.seed()
        
        return "Finished seeding (Check the server logs to double check nothing failed)"
    }
}
