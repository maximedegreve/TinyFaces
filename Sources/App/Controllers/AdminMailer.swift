//
//  AdminMailer.swift
//  MarvelFaces
//
//  Created by Maxime De Greve on 14/01/2017.
//
//

import Foundation
import Vapor
import SMTP
import Transport


final class AdminMailer {

    static func send(body: String) throws -> Bool {
    
        let credentials = SMTPCredentials(user: "maximedegreve@me.com", pass: "fGzdb6wRDHrYyUXp")
        let from = EmailAddress(name: "Password Rest", address: "maximedegreve@me.com")
        let to = EmailAddress(name: "Password Rest", address: "maximedegreve@me.com")
        let email = Email(
            from: from,
            to: to,
            subject: "Vapor SMTP - Simple",
            body: body
        )
    
        let client = try SMTPClient<TCPClientStream>.init(host: "smtp-relay.sendinblue.com", port: 587, securityLayer: .tls(nil))
        let (code, reply) = try client.send(email, using: credentials)
        print("Successfully sent email: \(code) \(reply)")
        
        return true

    }

}
