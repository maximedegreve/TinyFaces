//
//  NewFaceController.swift
//  MarvelFaces
//
//  Created by Maxime De Greve on 13/12/2016.
//
//

import Vapor
import HTTP
import SMTP

final class NewFaceController {
    
    func addRoutes(drop: Droplet) {
        drop.get("new-face",handler: newFace)
        drop.get("add") { (request) -> ResponseRepresentable in
            return try drop.view.make("add")
        }
    }
    
    func newFace(request: Request) throws -> ResponseRepresentable {
        
        guard let access_token = try request.session().data["accessToken"]?.string else {
            return try drop.view.make("index")
        }

        if var face = self.facebookUserDataToFace(accessToken: access_token) {
            
            let found = try User.query().filter("facebook_id", face.facebookId).all()
            
            if found.isEmpty {
                
                try face.save()
                
                return try drop.view.make("success", [
                    "title": "Your avatar was added to the queue to be approved.",
                    "subtitle": "We will notify you by email once your avatar got approved. If we reject it we will give more information regarding this."
                    ])
                
            } else {
                
                if found[0].approved == true {
                    return try drop.view.make("success", [
                        "title": "Your avatar was approved and added to the API.",
                        "subtitle": "If at any point you have any questions don't hesitate to contact us."
                        ])
                } else {
                    return try drop.view.make("success", [
                        "title": "Your avatar is still in the queue to be approved.",
                        "subtitle": "We will notify you by email once your avatar got approved. If we reject it we will give more information regarding this."
                        ])
                    
                }
                
            }

        }
        
        return try drop.view.make("error", [
            "message": "Something went wrong adding you to the database."
            ])
        
    }
    
    func uploadFacebookImageForFace(user: User) {
        
        let imageUrl = "https://graph.facebook.com/" + String(user.facebookId) + "/picture?width=1024&height=1024"
        var result: Response?
        
        do {
            result = try drop.client.get(imageUrl)
        } catch let error {
            Swift.print(error)
        }
        
        
        // JPEG
        if let contentType = result?.headers["Content-Type"], contentType.contains("image/jpeg"), let bytes = result?.body.bytes {
            Swift.print(bytes)
        }
        
    }
    
    func facebookUserDataToFace(accessToken: String) -> User? {
        do {
            let response = try drop.client.get("https://graph.facebook.com/v2.5/me/?fields=id,name,email,link,gender,verified&access_token=" + accessToken, headers: ["Content-Type": "application/json", "Accept": "application/json"])
            
            let failedMessage = "ERROR: Facebook user data could not be generated because of the missing field: "
            
            Swift.print(response.json.debugDescription)
            
            guard let facebook_id = response.json?["id"]?.string else {
                Swift.print(failedMessage + "id")
                Swift.print(response.json.debugDescription)
                return nil
            }
            
            guard let name = response.json?["name"]?.string else {
                Swift.print(failedMessage + "name")
                Swift.print(response.json.debugDescription)
                return nil
            }
            
            guard let email = response.json?["email"]?.string else {
                Swift.print(failedMessage + "email")
                Swift.print(response.json.debugDescription)
                return nil
            }
            
            guard let link = response.json?["link"]?.string else {
                Swift.print(failedMessage + "link")
                Swift.print(response.json.debugDescription)
                return nil
            }
            
            guard let gender = response.json?["gender"]?.string else {
                Swift.print(failedMessage + "gender")
                Swift.print(response.json.debugDescription)
                return nil
            }
            
            guard let verified = response.json?["verified"]?.int else {
                Swift.print(failedMessage + "verified")
                Swift.print(response.json.debugDescription)
                return nil
            }
            
            return User(facebookId: facebook_id, name: name, gender: gender, facebookProfileLink: link, email: email, verified: verified)
            
            
        } catch let error {
            Swift.print(error)
        }
        return nil
    }

    
}
