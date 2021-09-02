import Vapor
import Fluent

final class AddController {

    func index(request: Request) throws -> EventLoopFuture<View> {

        struct GenderValue: Encodable {
            var value: String
            var name: String
        }
        
        struct AddContext: Encodable {
            var facebookAppId: String
            var genders: [GenderValue]
        }

        let genderValues = Gender.allCases.map{$0.rawValue}

        let genders: [GenderValue] = genderValues.map { genderValue in
            let name = genderValue.replacingOccurrences(of: "_", with: " ").capitalized
            return GenderValue(value: genderValue, name: name)
        }
        
        return request.view.render("add", AddContext(facebookAppId: Environment.facebookAppId, genders: genders))

    }

}
