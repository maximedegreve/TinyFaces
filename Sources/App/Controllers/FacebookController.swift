import Vapor
import Fluent

final class FacebookController {

    let facebookAPI = "https://graph.facebook.com/v11.0"

    struct RequestData: Error, Content {
        var accessToken: String
        
        enum CodingKeys: String, CodingKey {
            case accessToken = "access_token"
        }

    }
    
    func process(request: Request) throws -> EventLoopFuture<Response> {
        
        let data = try request.query.decode(RequestData.self)
        
        return self.facebookMe(accessToken: data.accessToken, request: request).flatMap { meResponse in
            return self.facebookPicture(accessToken: data.accessToken, id: meResponse.id, request: request).flatMap { pictureResponse in
                print(pictureResponse)
                let response = Response(status: .ok, body: "All good")
                return request.eventLoop.future(response)
            }
        }

    }

    struct FacebookMeAgeRange: Content {
        var min: Int?
    }
    
    struct FacebookMeResponse: Content {
        var name: String
        var id: String
        var birthday: String
        var ageRange: FacebookMeAgeRange
        
        enum CodingKeys: String, CodingKey {
            case name
            case id
            case birthday
            case ageRange = "age_range"
        }
    }

    func facebookMe(accessToken: String, request: Request) -> EventLoopFuture<FacebookMeResponse> {
        
        return request.client.get("\(facebookAPI)/me") { req in
            req.headers = [
                "Accept": "application/json",
            ]
            try req.query.encode([
                "fields": "id,name,birthday,age_range",
                "access_token": accessToken,
            ])
        }.flatMapThrowing { response -> FacebookMeResponse in
            return try response.content.decode(FacebookMeResponse.self)
        }
        
    }
    
    struct FacebookPictureResponseData: Content {
        var url: String
    }
    
    struct FacebookPictureResponse: Content {
        var data: FacebookPictureResponseData
    }
    
    func facebookPicture(accessToken: String, id: String, request: Request) -> EventLoopFuture<FacebookPictureResponse> {
        
        return request.client.get("\(facebookAPI)/\(id)/picture") { req in
            req.headers = [
                "Accept": "application/json",
            ]
            try req.query.encode([
                "redirect": "false",
                "type": "large",
                "width": "5000",
                "access_token": accessToken,
            ])
        }.flatMapThrowing { response -> FacebookPictureResponse in
            return try response.content.decode(FacebookPictureResponse.self)
        }
        
    }
}
