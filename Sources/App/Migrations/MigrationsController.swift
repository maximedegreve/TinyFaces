//
//  MigrationsController.swift
//  MarvelFaces
//
//  Created by Maxime De Greve on 04/02/2017.
//
//

import Vapor
import Foundation
import HTTP

// Basic migrations on the database happen inside the models.
// But this is for automaticcly populating data after this migrations finished

final class MigrationsController {
    
    func addRoutes(drop: Droplet) {
        drop.get("migrate", handler: seed)
    }
    
    func seed(request: Request) throws -> ResponseRepresentable {
        
        try background {
            AvatarAddWidthHeight.populate()
        }
        
        return Response(status: .ok, body: "Migrations started")
        
    }
}
