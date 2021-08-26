import Vapor
import Fluent

final class Facebook {

    static let api = "https://graph.facebook.com/v11.0"

    static func me(accessToken: String, request: Request) -> EventLoopFuture<FacebookMeResponse> {

        return request.client.get("\(self.api)/me") { req in
            req.headers = [
                "Accept": "application/json"
            ]
            try req.query.encode([
                "fields": "id,name,birthday,age_range,email",
                "access_token": accessToken
            ])
        }.flatMapThrowing { response -> FacebookMeResponse in
            return try response.content.decode(FacebookMeResponse.self)
        }

    }

    static func picture(accessToken: String, id: String, request: Request) -> EventLoopFuture<FacebookPictureResponse> {

        return request.client.get("\(self.api)/\(id)/picture") { req in
            req.headers = [
                "Accept": "application/json"
            ]
            try req.query.encode([
                "redirect": "false",
                "type": "large",
                "width": "5000",
                "access_token": accessToken
            ])
        }.flatMapThrowing { response -> FacebookPictureResponse in
            return try response.content.decode(FacebookPictureResponse.self)
        }

    }

}
