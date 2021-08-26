import Fluent
import Vapor

final class Avatar: Model, Content {
    static let schema = "avatars"

    @ID(custom: .id)
    var id: Int?

    @Parent(key: "source_id")
    var source: Source

    @Field(key: "url")
    var url: String

    @Enum(key: "gender")
    var gender: Gender

    @Field(key: "quality")
    var quality: Int

    @Field(key: "approved")
    var approved: Bool

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    @Timestamp(key: "deleted_at", on: .delete)
    var deletedAt: Date?

    init() { }

    init(url: String, sourceId: Int, gender: Gender, quality: Int, approved: Bool) {
        self.$source.id = sourceId
        self.url = url
        self.gender = gender
        self.quality = quality
        self.approved = approved
    }

}

extension Avatar {

    static func createIfNotExist(req: Request, sourceId: Int, externalUrl: String, gender: Gender, quality: Int, approved: Bool) -> EventLoopFuture<Avatar> {

        return Avatar.query(on: req.db).filter(\.$source.$id == sourceId).first().flatMap { optionalAvatar -> EventLoopFuture<Avatar> in

            if let avatar = optionalAvatar {
                return req.eventLoop.future(avatar)
            }
            
            return Cloudinary().upload(file: externalUrl, eager: CloudinaryPresets.avatarMaxSize, publicId: nil, folder: "facebook", transformation: nil, format: "jpg", client: req.client).flatMap { cloudinaryResponse in
                
                let newAvatar = Avatar(url: cloudinaryResponse.secureUrl, sourceId: sourceId, gender: gender, quality: quality, approved: approved)
                return newAvatar.save(on: req.db).transform(to: newAvatar)
                
            }

        }

    }

}
