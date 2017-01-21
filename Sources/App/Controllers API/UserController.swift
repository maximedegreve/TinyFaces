import Vapor
import HTTP
import FluentMySQL
import Fluent

final class UserController: ResourceRepresentable {
	
	fileprivate let defaultAmount = 20
    fileprivate let defaultQuality = 10
	
	func index(request: Request) throws -> ResponseRepresentable {
		
		var amount = defaultAmount
		
		if let amountParameter = request.data["amount"]?.int {
			
			guard amountParameter > 0 && amountParameter <= 20 else {
				throw Abort.badRequest
			}
			
			amount = amountParameter
			
		}
        
        var quality = defaultQuality
        
        if let qualityParameter = request.data["min-quality"]?.int {
            
            guard qualityParameter >= 0 && qualityParameter <= 10 else {
                throw Abort.badRequest
            }
            
            quality = qualityParameter
            
        }
		
		let users = try User.random(limit: Limit(count: amount, offset: 0), minQuality: quality)
		return try users.makeJSON(request: request)
	}
	
	func makeResource() -> Resource<User> {
		return Resource(
			index: index
		)
	}
	
}

extension Request {
	func user() throws -> User {
		guard let json = json else { throw Abort.badRequest }
		return try User(node: json)
	}
}
