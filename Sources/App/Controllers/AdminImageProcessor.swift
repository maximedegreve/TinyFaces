//
//  File.swift
//  MarvelFaces
//
//  Created by Maxime De Greve on 15/01/2017.
//
//

import Foundation
import Vapor
import SwiftGD
import HTTP

final class AdminImageProcessor {
    
    static let sizes = [
        "small": 200,
        "medium": 500,
        "large": 1000,
        "original": 4000
    ]
    
    static let avatarsPath = URL(fileURLWithPath: drop.workDir).appendingPathComponent("Public/data/avatars", isDirectory: true)
    
    static func createDifferentSizesOfImage(url: URL) -> [String : String]? {
        
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
    
    static func getDirectFacebookURL(url: String) throws -> URL?{
        
        let resp: Response = try BasicClient.get(url)
        if resp.status == .found {
            if let location = resp.headers["Location"] {
                if let url = URL(string:location){
                    return url
                }
            }
        }
        
        return nil
        
    }

    static func downloadImage(url: String) throws -> URL? {
        
        // This could be tidier but now Vapor doesn't forward 302's
        
        if let locationFound = try getDirectFacebookURL(url: url) {
            
            let result = try drop.client.get(locationFound.absoluteString)
            
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
            
        }
        
        return nil
    }

    
}
