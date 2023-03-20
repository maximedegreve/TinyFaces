import Vapor
import Fluent

final class LicenseController {

    func commercial(request: Request) throws -> EventLoopFuture<View> {
        return request.view.render("license-commercial")
    }
    
    func nonCommercial(request: Request) throws -> EventLoopFuture<View> {
        return request.view.render("license-non-commercial")
    }

}
