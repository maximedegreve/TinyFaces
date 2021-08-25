import Vapor
import Fluent

final class AddController {

    func index(request: Request) throws -> EventLoopFuture<View> {
        return request.view.render("add")
    }
    
    func submission(request: Request) throws -> EventLoopFuture<View> {
        return request.view.render("submission")
    }

}
