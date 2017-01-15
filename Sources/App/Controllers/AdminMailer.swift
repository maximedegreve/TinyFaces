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

    // Mailing will not work in a local environment because sending from a non secure location
    
    static let host = drop.config["smtp", "host"]?.string ?? ""
    static let port = drop.config["smtp", "port"]?.int ?? 25
    static let from = EmailAddress(name: "TinyFaces", address: "no-reply@tinyfac.es")
    static let credentials = SMTPCredentials(user: drop.config["smtp", "user"]?.string ?? "", pass: drop.config["smtp", "pass"]?.string ?? "")
    
    static func sendApproved(user: User) throws -> Bool {
    
        let to = EmailAddress(name: user.name, address: user.email)

        let email = Email(
            from: from,
            to: to,
            subject: "Your avatar on TinyFaces got accepted.",
            body: "Hi \(user.name),\n\nThank you for adding your avatar on TinyFaces.\nAfter reviewing your submission our team accepted your tiny face.\n\nKind regards,\n\nTinyFaces 👩🏻👨🏾👦🏼"
        )
    
        let client = try SMTPClient<TCPClientStream>.init(host: host, port: port, securityLayer: .none)
        let (code, reply) = try client.send(email, using: credentials)
        print("Successfully sent email: \(code) \(reply)")
        
        return true

    }
    
    static func sendRejected(user: User, reason: String) throws -> Bool {
        
        let to = EmailAddress(name: user.name, address: user.email)
        
        let email = Email(
            from: from,
            to: to,
            subject: "Your avatar on TinyFaces got rejected.",
            body: "Hi \(user.name),\n\nThank you for adding your avatar on TinyFaces.\nUnfortunately after reviewing your submission our team rejected your avatar.\n\nBecause: \(reason)\n\nFeel free to submit your Facebook profile again once you've changed your profile picture to something which would fit our guidelines.\n\nKind regards,\n\nTinyFaces 👩🏻👨🏾👦🏼"
        )
        
        let client = try SMTPClient<TCPClientStream>.init(host: host, port: port, securityLayer: .none)
        let (code, reply) = try client.send(email, using: credentials)
        print("Successfully sent email: \(code) \(reply)")
        
        return true
        
    }

}
