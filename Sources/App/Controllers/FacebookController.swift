import Vapor
import Fluent

final class FacebookController {

    struct RequestData: Error, Content {
        var accessToken: String
        var gender: Gender

        enum CodingKeys: String, CodingKey {
            case accessToken = "access_token"
            case gender
        }

    }

    func process(request: Request) throws -> EventLoopFuture<Response> {

        let data = try request.content.decode(RequestData.self)

        return Facebook.me(accessToken: data.accessToken, request: request).flatMap { meResponse in

            return Facebook.picture(accessToken: data.accessToken, id: meResponse.id, request: request).flatMap { pictureResponse in

                return Source.createIfNotExist(req: request, name: meResponse.name, email: meResponse.email, externalId: meResponse.id, platform: .Facebook).flatMap { source in
                    
                    guard let sourceId = source.id else {
                        return request.eventLoop.makeFailedFuture(Abort(.internalServerError, reason: "Missing source id. Contact our support."))
                    }
                    
                    return Avatar.createIfNotExist(req: request, sourceId: sourceId, externalUrl: pictureResponse.data.url, gender: data.gender, quality: 0, approved: false).flatMap { avatar in
                        
                        guard let avatarId = avatar.id else {
                            return request.eventLoop.makeFailedFuture(Abort(.internalServerError, reason: "Missing avatar id. Contact our support."))
                        }
                        
                        struct ResponseData: Error, Content {
                            var avatarId: Int

                            enum CodingKeys: String, CodingKey {
                                case avatarId = "avatar_id"
                            }

                        }
                        
                        return ResponseData(avatarId: avatarId).encodeResponse(for: request)
                        
                    }

                }

            }

        }

    }

}
