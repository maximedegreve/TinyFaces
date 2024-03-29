import Fluent
import Vapor

final class Analytic: Model, Content {
    static let schema = "analytics"

    @ID(custom: .id)
    var id: Int?

    @Field(key: "date")
    var date: Date

    @Field(key: "requests")
    var requests: Int

    @Field(key: "ip")
    var ip: String

    init() { }

    init(date: Date, requests: Int, ip: String) {
        self.date = date
        self.requests = requests
        self.ip = ip
    }

    static func log(request: Request) async throws {

        guard let ip = request.peerAddress?.ipAddress else {
            return request.logger.warning("⚠️ Missing IP in request: \(request.description)")
        }

        let existing = try await Analytic.query(on: request.db).filter(\.$ip == ip).filter(\.$date == Date().startOfDay).first()
        let analytic = existing ?? Analytic(date: Date().startOfDay, requests: 0, ip: ip)

        analytic.requests = analytic.requests + 1
        try await analytic.save(on: request.db)

    }

}
