import Vapor

struct FacebookMeAgeRange: Content {
    var min: Int?
}

struct FacebookMeResponse: Content {
    var name: String
    var id: String
    var birthday: String
    var gender: String?
    var email: String
    var ageRange: FacebookMeAgeRange

    enum CodingKeys: String, CodingKey {
        case name
        case id
        case birthday
        case gender
        case email
        case ageRange = "age_range"
    }
}
