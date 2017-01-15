//
//  NewFaceController.swift
//  MarvelFaces
//
//  Created by Maxime De Greve on 13/12/2016.
//
//

import Vapor
import Foundation
import HTTP


final class AdminController {

    func addRoutes(drop: Droplet) {
        drop.get("admin", handler: index)
        drop.post("admin", handler: post)
    }
    
    func post(request: Request) throws -> ResponseRepresentable {
        
        guard let access_token = try request.session().data["accessToken"]?.string else {
            return Response(redirect: "../login-with-facebook?redirect=/admin")
        }
        
        if facebookUserIsAdminAllowed(accessToken: access_token) == false {
            return Response(redirect: "../")
        }
        
        if let acceptId = request.data["accept_id"]?.int {
            
        }
        
    }
    
    func index(request: Request) throws -> ResponseRepresentable {
        
        
        let user = try User.query().first()
        try AdminMailer.sendRejected(user: user!, reason: "Illustrations are not allowed")
        
        
        guard let access_token = try request.session().data["accessToken"]?.string else {
            return Response(redirect: "../login-with-facebook?redirect=/admin")
        }
        
        if facebookUserIsAdminAllowed(accessToken: access_token) == false {
            return Response(redirect: "../")
        }
        
        let notApproved = try User.query().filter("approved", .equals, false).all().makeNode()
        
        return try drop.view.make("admin", [
            "faces": notApproved
            ])
                
    }
    
    func all(request: Request) throws -> ResponseRepresentable {
        
        guard let access_token = try request.session().data["accessToken"]?.string else {
            return Response(redirect: "../login-with-facebook?redirect=/admin")
        }
        
        if facebookUserIsAdminAllowed(accessToken: access_token) == false {
            return Response(redirect: "../")
        }
        
        let approved = try User.query().filter("approved", .equals, true).all().makeNode()
        
        return try drop.view.make("adminApproved", [
            "faces": approved
            ])
        
    }
    
    func reject(request: Request) throws -> ResponseRepresentable{
        
        guard let access_token = try request.session().data["accessToken"]?.string else {
            return Response(redirect: "../login-with-facebook?redirect=/admin")
        }
        
        if facebookUserIsAdminAllowed(accessToken: access_token) == false {
            return Response(redirect: "../")
        }
        
        if let acceptId = request.data["reject_id"]?.int {
            
            if let user = try User.find(acceptId) {
                _ = try AdminMailer.sendApproved(user: user)
            }
            
        }
        
        return try index(request: request)
        
    }
    
    func toPublicURLString(url: String) -> String {
        
        if let range = url.range(of: "Public/") {
            let result = url.substring(from: range.upperBound)
            return result
        }
        return url
    }
        
    func accept(request: Request) throws -> ResponseRepresentable {
        
        guard let access_token = try request.session().data["accessToken"]?.string else {
            return Response(redirect: "../login-with-facebook?redirect=/admin")
        }
        
        if facebookUserIsAdminAllowed(accessToken: access_token) == false {
            return Response(redirect: "../")
        }
        
        if let acceptId = request.data["accept_id"]?.int {
            
            if let face = try User.find(acceptId) {
                
                let imageUrl = "https://graph.facebook.com/" + String(face.facebookId) + "/picture?width=2000&type=square"
                
                if let fileURL = try AdminImageProcessor.downloadImage(url: imageUrl) {
                    
                    if let sizesURLs = AdminImageProcessor.createDifferentSizesOfImage(url: fileURL) {
                        
                        var faceNew = face
                        faceNew.approved = true
                        try faceNew.save()
                        
                        for (sizeName, url) in sizesURLs {
                            var avatar = Avatar(url: toPublicURLString(url: url), size: sizeName, userId: faceNew.id!)
                            try avatar.save()
                        }
                        
                        
                        
                    }
                    
                }
 
            }
            
        }
        
        return try index(request: request)
        
    }
        
    func facebookUserIsAdminAllowed(accessToken: String) -> Bool {
        do {
            let response = try drop.client.get("https://graph.facebook.com/v2.5/me/?fields=id&access_token=" + accessToken, headers: ["Content-Type": "application/json", "Accept": "application/json"])
            
            if let facebook_id = response.json?["id"]?.string {
                
                if facebook_id == "10154849380747704"{
                    return true
                }
                
            }
            
        } catch let error {
            Swift.print(error)
        }
        
        return false
    }

}
