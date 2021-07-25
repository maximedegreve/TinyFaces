import Vapor

final class SendInBlue {

    let apiUrl = URI(string: "https://api.sendinblue.com/v3/smtp/email")

    func sendEmail(email: SendInBlueEmail, client: Client) -> EventLoopFuture<Bool> {

        guard let sendInBlueKey = Environment.sendInBlueKey else {
            return client.eventLoop.makeFailedFuture(Abort(.badRequest, reason: "Missing `SEND_IN_BLUE_KEY` environment variable."))
        }

        let request = client.post(self.apiUrl) { req in
            req.headers = [
                "Content-type": "application/json",
                "api-key": sendInBlueKey
            ]
            try req.content.encode(email)
        }

        return request.flatMap { (response) -> EventLoopFuture<Bool> in
            return request.eventLoop.future(response.status.code == 201)
        }

    }

}
