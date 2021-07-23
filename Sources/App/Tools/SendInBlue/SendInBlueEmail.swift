import Vapor

struct SendInBlueEmail: Content {
    var sender: SendInBlueContact
    var to: [SendInBlueContact]
    var subject: String
    var htmlContent: String

    enum CodingKeys: String, CodingKey {
        case sender
        case to
        case htmlContent = "htmlContent"
        case subject
    }
}

