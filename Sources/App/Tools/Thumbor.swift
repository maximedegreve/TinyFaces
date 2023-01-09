//
//  Cloudinary.swift
//  App
//
//  Created by Maxime on 26/06/2020.
//

import Foundation
import Vapor
import Crypto

enum ThumborHorizontalAlign: String {
    case left = "left"
    case center = "center"
    case right = "right"
}

enum ThumborVerticalAlign: String {
    case top = "top"
    case middle = "middle"
    case bottom = "bottom"
}

struct ThumborCropCoordinates {
    var x: Int
    var y: Int
}

struct ThumborSize {
    var width: Int
    var height: Int
}


struct ThumborCropPoints {
    var topLeft: ThumborCropCoordinates
    var bottomRight: ThumborCropCoordinates
}

final public class Thumbor {
    
    func secure(url: String, trim: Bool = false, fitIn: Bool = false, exEf: Bool = false, horizontalAlign: ThumborHorizontalAlign? = nil, verticalAlign: ThumborVerticalAlign? = nil, crop: ThumborCropPoints? = nil, size: ThumborSize? = nil, smart: Bool = false) -> String {
        
        ///hmac/trim/AxB:CxD/(adaptive-)(full-)fit-in/-Ex-F/HALIGN/VALIGN/smart/filters:FILTERNAME(ARGUMENT):FILTERNAME(ARGUMENT)/*IMAGE-URI*

        var path = [String]()
        
        if(trim){
            // trim removes surrounding space in images using top-left pixel color unless specified otherwise;
            path.append("trim")
        }
        
        if let crop = crop{
            // AxB:CxD means manually crop the image at left-top point AxB and right-bottom point CxD;
            path.append("\(crop.topLeft.x)x\(crop.topLeft.y):\(crop.bottomRight.x)x\(crop.bottomRight.y)")
        }
        
        if let size = size {
            path.append("\(size.width)x\(size.height)")
        }
        
        if(fitIn){
            //fit-in means that the generated image should not be auto-cropped and otherwise just fit in
            // an imaginary box specified by ExF. If a full fit-in is specified, then the largest size is
            // used for cropping (width instead of height, or the other way around). If adaptive fit-in
            // is specified, it inverts requested width and height if it would get a better image definition
            path.append("fit-in")
        }
        
        if(exEf){
            //-Ex-F means resize the image to be ExF of width per height size. The minus signs mean flip
            // horizontally and vertically
            path.append("-Ex-F")
        }
        
        if let horizontalAlign = horizontalAlign {
            // HALIGN is horizontal alignment of crop
            path.append(horizontalAlign.rawValue)
        }
        
        if let verticalAlign = verticalAlign {
            // VALIGN is vertical alignment of crop
            path.append(verticalAlign.rawValue)
        }
        
        if smart {
            // Smart means using smart detection of focal points;
            path.append("smart")
        }
            
        path.append(url)
                
        let pathJoined = String(path.joined(separator:"/"))
        let signature = createSignature(path: pathJoined)

        return "\(Environment.thumborUrl)/\(signature)/\(pathJoined)"

    }

    private func createSignature(path: String) -> String {

        let key = SymmetricKey(data: Data(Environment.thumborKey.utf8))
        let data = Data(path.utf8)
        let sign = Data(HMAC<Insecure.SHA1>.authenticationCode(for: data, using: key))
        let encodedSign = sign.base64EncodedString().replacingOccurrences(of: "+", with: "-").replacingOccurrences(of: "/", with: "_")

        return encodedSign
    }

}
