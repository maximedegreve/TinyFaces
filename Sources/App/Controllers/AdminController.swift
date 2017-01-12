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
import SwiftGD

final class AdminController {
    
    let avatarsPath = URL(fileURLWithPath: drop.workDir).appendingPathComponent("Public/data/avatars", isDirectory: true)
	
	// TODO: use enum
    let sizes = [
        "small": 200,
        "medium": 500,
        "large": 1000,
        "original": 4000
    ]
    
    func addRoutes(drop: Droplet) {
        drop.get("admin", handler: index)
        drop.get("admin", "approved", handler: index)
        drop.post("admin", handler: accept)
    }
    
    func index(request: Request) throws -> ResponseRepresentable {
        
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
                
                if let fileURL = downloadImage(url: imageUrl) {
                    
                    if let sizesURLs = createDifferentSizesOfImage(url: fileURL) {
                        
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
    
    func createDifferentSizesOfImage(url: URL) -> [String : String]? {
        
        let originalImage = Image(url: url)
        
        let fileName = url.deletingPathExtension().lastPathComponent
        
        var result = [String : String]()
        
        for (sizeKey, sizeValue) in sizes {
            
            if sizeKey == "original" {
                result[sizeKey] = url.absoluteString
            } else {
                
                let fileExtension = "-\(sizeValue)w.jpeg"
                let resizedImage = originalImage?.resizedTo(width: sizeValue, applySmoothing: true)
                let saveURL = avatarsPath.appendingPathComponent(fileName + fileExtension, isDirectory: false)
                
                if resizedImage?.write(to: saveURL, quality: 90) == true {
                    result[sizeKey] = saveURL.absoluteString
                } else {
                    print("One of the images failed resizing")
                    return nil
                }
            }            
            
        }
        
        return result

    }
    
    func toPublicURLString(url: String) -> String {
        
        if let range = url.range(of: "Public/") {
            let result = url.substring(from: range.upperBound)
            return result
        }
        return url
    }
    
    func downloadImage(url: String) -> URL? {

        // This could be tidier but now Vapor doesn't forward 302's
        
        var locationImage: String?
        
        do {
            let resp: Response = try BasicClient.get(url)
            if resp.status == .found {
                if let location = resp.headers["Location"] {
                    locationImage = location
                }
            }
        } catch let error {
            Swift.print(error)
        }

        if let locationFound = locationImage {
            
            do {
                let result = try drop.client.get(locationFound)
                
                if let contentType = result.headers["Content-Type"], contentType.contains("image/jpeg"), let bytes = result.body.bytes {
                    
                    let uuid = UUID().uuidString
                    let saveURL = avatarsPath.appendingPathComponent(uuid + ".jpeg", isDirectory: false)

                    do {
                        let data = Data(bytes: bytes)
                        try data.write(to: saveURL)
                        return saveURL
                    } catch {
                        Swift.print("Unable to write multipart form data to file. Underlying error \(error)")
                    }
                    
                }
                
            } catch let error {
                Swift.print(error)
            }
            
        }
        
        return nil
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
