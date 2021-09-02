import Vapor

struct FacebookMeResponse: Content {
    var name: String
    var id: String
    var email: String

    enum CodingKeys: String, CodingKey {
        case name
        case id
        case email
    }
}
