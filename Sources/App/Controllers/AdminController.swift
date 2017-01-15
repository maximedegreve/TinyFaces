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
        drop.get("admin","users","approved", handler: approved)
        drop.get("admin","review",":id", handler: review)
        drop.post("admin", handler: post)
    }
    
    func review(request: Request) throws -> ResponseRepresentable {
        
        guard let access_token = try request.session().data["accessToken"]?.string else {
            return Response(redirect: "../login-with-facebook?redirect=/admin")
        }
        
        if facebookUserIsAdminAllowed(accessToken: access_token) == false {
            return Response(redirect: "../")
        }
        
        guard let userId = request.parameters["id"]?.int else {
            throw Abort.badRequest
        }
        
        guard let user = try User.find(userId) else {
            throw Abort.badRequest
        }
        
        return try drop.view.make("admin/review", [
            "user_id": userId,
            "user_facebook_id": user.facebookId
            ])
        
    }
    
    func post(request: Request) throws -> ResponseRepresentable {
        
        guard let access_token = try request.session().data["accessToken"]?.string else {
            return Response(redirect: "../login-with-facebook?redirect=/admin")
        }
        
        if facebookUserIsAdminAllowed(accessToken: access_token) == false {
            return Response(redirect: "../")
        }
        
        if let action = request.data["action"]?.string{
            
            switch action {
            case "accept":
                return try accept(request: request)
            case "reject":
                return try reject(request: request)
            default:
                Swift.print("Unknown admin action")
            }
            
        }

        return try drop.view.make("error", [
            "message": "Not sure what admin action you want to do here."
            ])
        
    }
    
    func index(request: Request) throws -> ResponseRepresentable {

        guard let access_token = try request.session().data["accessToken"]?.string else {
            return Response(redirect: "../login-with-facebook?redirect=/admin")
        }
        
        if facebookUserIsAdminAllowed(accessToken: access_token) == false {
            return Response(redirect: "../")
        }
        
        let notApproved = try User.query().filter("approved", .equals, false).all().makeNode()
        
        return try drop.view.make("admin/admin", [
            "users": notApproved
            ])
                
    }
    
    func reject(request: Request) throws -> ResponseRepresentable{
        
        if let reason = request.data["reason"]?.string, let userId = request.data["user_id"]?.int{
            
            if let user = try User.find(userId) {
                if try AdminMailer.sendRejected(user: user, reason: reason){
                    try User.query().delete(user)
                    return try index(request: request)
                }
            }

        }
        
        return try drop.view.make("error", [
            "message": "Something went wrong"
            ])
        
    }

    func accept(request: Request) throws -> ResponseRepresentable {
        
        if let userId = request.data["user_id"]?.int{
            
            if let user = try User.find(userId) {
                
                let imageUrl = "https://graph.facebook.com/" + String(user.facebookId) + "/picture?width=2000&type=square"
                
                if let fileURL = try AdminImageProcessor.downloadImage(url: imageUrl) {
                    
                    if let sizesURLs = AdminImageProcessor.createDifferentSizesOfImage(url: fileURL) {
                        
                        var userEdited = user
                        userEdited.approved = true
                        try userEdited.save()
                        
                        for (sizeName, url) in sizesURLs {
                            var avatar = Avatar(url: toPublicURLString(url: url), size: sizeName, userId: userEdited.id!)
                            try avatar.save()
                        }
                        
                        if try AdminMailer.sendApproved(user: user){
                            return try index(request: request)
                        }
                        
                    }
                    
                }
 
            }
            
        }
        
        return try drop.view.make("error", [
            "message": "Something went wrong"
            ])
        
    }
    
    func approved(request: Request) throws -> ResponseRepresentable {
        
        guard let access_token = try request.session().data["accessToken"]?.string else {
            return Response(redirect: "../login-with-facebook?redirect=/admin")
        }
        
        if facebookUserIsAdminAllowed(accessToken: access_token) == false {
            return Response(redirect: "../")
        }
        
        let approved = try User.query().filter("approved", .equals, true).all().makeNode()
        
        return try drop.view.make("admin/approved", [
            "users": approved
            ])
        
    }
    
    func toPublicURLString(url: String) -> String {
        
        if let range = url.range(of: "Public/") {
            let result = url.substring(from: range.upperBound)
            return result
        }
        return url
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
