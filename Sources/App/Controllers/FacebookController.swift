import Vapor
import Fluent

final class FacebookController {

    struct RequestData: Error, Content {
        var accessToken: String
        
        enum CodingKeys: String, CodingKey {
            case accessToken = "access_token"
        }

    }
    
    func process(request: Request) throws -> EventLoopFuture<Response> {
        
        let data = try request.query.decode(RequestData.self)
        
        return Facebook.me(accessToken: data.accessToken, request: request).flatMap { meResponse in
            
            return Facebook.picture(accessToken: data.accessToken, id: meResponse.id, request: request).flatMap { pictureResponse in
                
                guard
                    let ageRangeMin = meResponse.ageRange.min,
                    ageRangeMin >= 21 else {
                    return request.eventLoop.makeFailedFuture(Abort(.conflict, reason: "You have to be at least 21 years old"))
                }
                
                return Source.createIfNotExist(req: request, name: meResponse.name, email: meResponse.email, externalId: meResponse.id, platform: .Facebook).flatMap { source in
                    
                    let response = Response(status: .ok, body: "All good")
                    return request.eventLoop.future(response)
                    
                }
                
            }
            
        }

    }

}
