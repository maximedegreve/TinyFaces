import Vapor
import Queues
import Fluent

struct EmailJob: AsyncJob {

    typealias Payload = SendInBlueEmail

    func dequeue(_ context: QueueContext, _ payload: Payload) async throws {
        _ = try await SendInBlue().sendEmail(email: payload, client: context.application.client)
    }

}
